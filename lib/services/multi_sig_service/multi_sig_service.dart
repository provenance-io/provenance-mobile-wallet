import 'dart:async';

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
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
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

  final items = <MultiSigPendingTx>[];

  final _actionItemsBySignerAddress = <String, List<MultiSigPendingTx>>{};
  final _initialized = Completer();

  final _main = StoreRef<String, Map<String, Object?>?>.main();
  late final Future<Database> _db;

  Future<void> get initialized => _initialized.future;

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
      _cacheMultiSigItem(tx);
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
          _cacheMultiSigItem(tx);
        }
      }
    }

    _publish();

    if (!_initialized.isCompleted) {
      _initialized.complete();
    }
  }

  Future<String?> createTx({
    required String multiSigAddress,
    required String signerAddress,
    required wallet.Coin coin,
    required p.TxBody txBody,
    required p.Fee fee,
  }) async {
    final remoteId = await _multiSigClient.createTx(
      multiSigAddress: multiSigAddress,
      signerAddress: signerAddress,
      coin: coin,
      txBody: txBody,
      fee: fee,
    );

    await sync(
      signerAddresses: [
        signerAddress,
      ],
    );

    return remoteId;
  }

  Future<bool> signTx({
    required String signerAddress,
    required wallet.Coin coin,
    required String txUuid,
    required String signatureBytes,
  }) async {
    final success = await _multiSigClient.signTx(
      signerAddress: signerAddress,
      coin: coin,
      txUuid: txUuid,
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

  Future<void> finalizeTx({
    required String signerAddress,
    required String txUuid,
    required TxResponse response,
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
  }

  void _cacheMultiSigItem(MultiSigPendingTx tx) {
    if (!_actionItemsBySignerAddress.containsKey(tx.signerAddress)) {
      _actionItemsBySignerAddress[tx.signerAddress] = [];
    }

    _actionItemsBySignerAddress[tx.signerAddress]!.add(tx);
  }

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
        .fold<List<MultiSigPendingTx>>(
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
