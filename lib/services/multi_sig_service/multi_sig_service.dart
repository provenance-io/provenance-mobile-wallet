import 'dart:async';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart' as convert;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provenance_dart/proto.dart' as p;
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet.dart' as wallet;
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_status.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_pending_tx.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signature.dart';
import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/mixin/listenable_mixin.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_error.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/default_transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/service_tx_response.dart';
import 'package:provenance_wallet/util/extensions/generated_message_extension.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/subjects.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class MultiSigService extends Listenable with ListenableMixin {
  MultiSigService({
    required AccountService accountService,
    required MultiSigClient multiSigClient,
  })  : _accountService = accountService,
        _multiSigClient = multiSigClient {
    _db = _initDb();
  }

  Future<Database> _initDb() async {
    final directory = await getApplicationDocumentsDirectory();
    await directory.create(recursive: true);

    final factory = databaseFactoryIo;

    final path = p.join(directory.path, 'multi_sig_service.db');

    final db = await factory.openDatabase(
      path,
      version: 1,
    );

    return db;
  }

  final AccountService _accountService;
  final MultiSigClient _multiSigClient;

  final items = <MultiSigActionListItem>[];

  final _actionItemsBySignerAddress = <String, List<MultiSigActionListItem>>{};
  final _initialized = Completer();
  final _response = PublishSubject<ServiceTxResponse>();

  final _main = StoreRef<String, Map<String, Object?>?>.main();
  late final Future<Database> _db;

  Future<void> get initialized => _initialized.future;
  Stream<ServiceTxResponse> get response => _response;

  Future<void> sync({
    required List<String> signerAddresses,
  }) async {
    final pendingTxs = await _multiSigClient.getPendingTxs(
      signerAddresses: signerAddresses,
    );

    if (pendingTxs == null) {
      logDebug('Sync failed to get pending txs');
      return;
    }

    final createdTxs = await _multiSigClient.getCreatedTxs(
      signerAddresses: signerAddresses,
      status: MultiSigStatus.ready,
    );

    if (createdTxs == null) {
      logDebug('Sync failed to get created txs');
      return;
    }

    _actionItemsBySignerAddress.clear();

    for (final tx in pendingTxs) {
      final item = _toSignListItem(tx);
      _cacheMultiSigItem(item);
    }

    for (final tx in createdTxs) {
      if (tx.signatures != null) {
        final ref = _main.record(tx.txUuid);
        final db = await _db;
        final result = await ref.get(db);
        if (result != null) {
          final model = _SembastResultData.fromRecord(result);
          final success = await _multiSigClient.updateTxResult(
            txUuid: model.txUuid,
            txHash: model.txHash,
            coin: ChainId.toCoin(model.chainId),
          );

          if (success) {
            await ref.delete(db);
          }
        } else {
          final item = _toTransmitListItem(tx);
          _cacheMultiSigItem(item);
        }
      }
    }

    _publish();

    if (!_initialized.isCompleted) {
      _initialized.complete();
    }
  }

  Future<bool> sign(
      ActionListGroup group, MultiSigSignActionListItem item) async {
    final accountId = group.accountId;
    final account =
        await _accountService.getAccount(accountId) as TransactableAccount;
    final coin = account.coin;
    final pbClient = await get<ProtobuffClientInjector>().call(coin);

    final authBytes = await _sign(
      pbClient: pbClient,
      multiSigAddress: item.multiSigAddress,
      signerAccountId: accountId,
      txBody: item.txBody,
      fee: item.fee,
    );

    final signatureBytes = convert.hex.encode(authBytes);

    final success = await _multiSigClient.signTx(
      signerAddress: item.signerAddress,
      coin: coin,
      txUuid: item.txUuid,
      signatureBytes: signatureBytes,
    );

    if (success) {
      // Fetch all in case creator and co-signer are both in same app
      final addresses = (await _accountService.getAccounts())
          .whereType<TransactableAccount>()
          .map((e) => e.address)
          .toList();

      await sync(
        signerAddresses: addresses,
      );
    }

    return success;
  }

  Future<void> transmit(MultiSigTransmitActionListItem item) async {
    final accounts = await _accountService.getTransactableAccounts();
    final multiSigAccount = accounts
        .whereType<MultiTransactableAccount>()
        .firstWhereOrNull((e) => e.linkedAccount.address == item.signerAddress);
    if (multiSigAccount == null) {
      throw ActionListError.multiSigAccountNotFound;
    }

    final coin = multiSigAccount.coin;
    final signerAccountId = multiSigAccount.linkedAccount.id;
    final pbClient = await get<ProtobuffClientInjector>().call(coin);

    final authBytes = await _sign(
      pbClient: pbClient,
      multiSigAddress: item.multiSigAddress,
      signerAccountId: signerAccountId,
      txBody: item.txBody,
      fee: item.fee,
    );

    final unorderedSignatures = {
      item.signerAddress: authBytes,
      ...item.signatures.asMap().map(
            (key, value) => MapEntry(
              value.signerAddress,
              convert.hex.decode(value.signatureHex),
            ),
          ),
    };

    final sigLookup = <String, List<int>>{};
    for (final publicKey in multiSigAccount.publicKey.publicKeys) {
      final address = publicKey.address;
      final sig = unorderedSignatures[address];
      if (sig != null) {
        sigLookup[address] = sig;
      }
    }

    final privateKey = wallet.AminoPrivKey(
      threshold: multiSigAccount.signaturesRequired,
      pubKeys: multiSigAccount.publicKey.publicKeys,
      coin: coin,
      sigLookup: sigLookup,
    );

    final responsePair = await pbClient.broadcastTransaction(
      item.txBody,
      [
        privateKey,
      ],
      item.fee,
    );

    // TODO-Roy: if is wallet connect, send update to wallet connect
    // Probably move multi-sig broadcast somewhere else and reference it both
    // here and in wallet connect delegate

    await _finalizeTx(
      signerAddress: item.signerAddress,
      txUuid: item.txUuid,
      response: responsePair.txResponse,
      coin: coin,
      fee: item.fee,
    );
  }

  Future<void> _finalizeTx({
    required String signerAddress,
    required String txUuid,
    required TxResponse response,
    required Fee fee,
    required wallet.Coin coin,
  }) async {
    final chainId = ChainId.forCoin(coin);

    final data = _SembastResultData(
      txUuid: txUuid,
      txHash: response.txhash,
      chainId: chainId,
    );

    final ref = _main.record(txUuid);
    final db = await _db;
    await ref.put(db, data.toRecord());

    final success = await _multiSigClient.updateTxResult(
      txUuid: txUuid,
      txHash: response.txhash,
      coin: coin,
    );

    if (success) {
      await ref.delete(db);
    }

    _actionItemsBySignerAddress[signerAddress]
        ?.removeWhere((e) => e.txUuid == txUuid);
    _publish();

    _response.add(
      ServiceTxResponse(
        code: response.code,
        message: response.rawLog,
        // gasUsed: response.gasUsed.toInt(),
        // gasWanted: response.gasWanted.toInt(),
        // height: response.height.toInt(),
        txHash: response.txhash,
        fees: fee.amount,
        codespace: response.codespace,
      ),
    );
  }

  Future<List<int>> _sign({
    required p.PbClient pbClient,
    required String multiSigAddress,
    required String signerAccountId,
    required p.TxBody txBody,
    required p.Fee fee,
  }) async {
    final signerRootPk = await _accountService.loadKey(signerAccountId);

    final signerPk = signerRootPk!.defaultKey();

    final multiSigBaseAccount = await pbClient.getBaseAccount(multiSigAddress);

    final authBytes = pbClient.generateMultiSigAuthorization(
      signerPk,
      txBody,
      fee,
      multiSigBaseAccount,
    );

    return authBytes;
  }

  void _cacheMultiSigItem(MultiSigActionListItem item) {
    if (!_actionItemsBySignerAddress.containsKey(item.signerAddress)) {
      _actionItemsBySignerAddress[item.signerAddress] = [];
    }

    _actionItemsBySignerAddress[item.signerAddress]!.add(item);
  }

  MultiSigTransmitActionListItem _toTransmitListItem(MultiSigPendingTx tx) =>
      MultiSigTransmitActionListItem(
        multiSigAddress: tx.multiSigAddress,
        signerAddress: tx.signerAddress,
        groupAddress: tx.multiSigAddress,
        label: (c) => tx.txBody.messages
            .map((e) => e.toMessage().toLocalizedName(c))
            .join(', '),
        subLabel: (c) => Strings.of(c).actionListSubLabelActionRequired,
        txBody: tx.txBody,
        fee: tx.fee,
        txUuid: tx.txUuid,
        signatures: tx.signatures!,
      );

  MultiSigSignActionListItem _toSignListItem(MultiSigPendingTx tx) =>
      MultiSigSignActionListItem(
        multiSigAddress: tx.multiSigAddress,
        signerAddress: tx.signerAddress,
        groupAddress: tx.signerAddress,
        label: (c) => tx.txBody.messages
            .map((e) => e.toMessage().toLocalizedName(c))
            .join(', '),
        subLabel: (c) => Strings.of(c).actionListSubLabelActionRequired,
        txBody: tx.txBody,
        fee: tx.fee,
        txUuid: tx.txUuid,
      );

  Future<void> remove({
    required List<String> signerAddresses,
  }) async {
    for (final address in signerAddresses) {
      _actionItemsBySignerAddress.remove(address);
    }

    _publish();
  }

  void _publish() {
    final updated = _actionItemsBySignerAddress.entries
        .fold<List<MultiSigActionListItem>>(
            [],
            (previousValue, element) =>
                previousValue..addAll(element.value)).toList();
    items.clear();
    items.addAll(updated);

    notifyListeners();
  }
}

abstract class MultiSigActionListItem implements ActionListItem {
  String get multiSigAddress;
  String get signerAddress;
  String get groupAddress;
  String get txUuid;
}

class MultiSigSignActionListItem implements MultiSigActionListItem {
  MultiSigSignActionListItem({
    required this.multiSigAddress,
    required this.signerAddress,
    required this.groupAddress,
    required this.label,
    required this.subLabel,
    required this.txBody,
    required this.fee,
    required this.txUuid,
  });

  @override
  final String multiSigAddress;

  @override
  final String signerAddress;

  @override
  final String groupAddress;

  final TxBody txBody;

  final Fee fee;

  @override
  final String txUuid;

  @override
  final LocalizedString label;

  @override
  final LocalizedString subLabel;
}

class MultiSigTransmitActionListItem implements MultiSigActionListItem {
  MultiSigTransmitActionListItem({
    required this.multiSigAddress,
    required this.signerAddress,
    required this.groupAddress,
    required this.label,
    required this.subLabel,
    required this.txBody,
    required this.fee,
    required this.txUuid,
    required this.signatures,
  });

  @override
  final String multiSigAddress;

  @override
  final String signerAddress;

  @override
  final String groupAddress;

  final TxBody txBody;

  final Fee fee;

  @override
  final String txUuid;

  @override
  final LocalizedString label;

  @override
  final LocalizedString subLabel;

  final List<MultiSigSignature> signatures;
}

class _SembastResultData {
  _SembastResultData({
    required this.txUuid,
    required this.txHash,
    required this.chainId,
  });

  final String txUuid;
  final String txHash;
  final String chainId;

  Map<String, dynamic> toRecord() => {
        'txUuid': txUuid,
        'txHash': txHash,
        'chainId': chainId,
      };

  // ignore: unused_element
  factory _SembastResultData.fromRecord(Map<String, dynamic> rec) =>
      _SembastResultData(
        txUuid: rec['txUuid'] as String,
        txHash: rec['txHash'] as String,
        chainId: rec['chainId'] as String,
      );
}
