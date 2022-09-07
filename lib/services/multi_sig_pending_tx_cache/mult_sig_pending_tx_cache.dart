import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet.dart' as wallet;
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/mixin/listenable_mixin.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
import 'package:provenance_wallet/services/models/service_tx_response.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_pending_tx.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_signature.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_status.dart';
import 'package:provenance_wallet/services/multi_sig_service/multi_sig_service.dart';
import 'package:provenance_wallet/util/extensions/generated_message_extension.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/subjects.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

// TODO-Roy: Rename to MultiSigService
class MultiSigPendingTxCache extends Listenable with ListenableMixin {
  MultiSigPendingTxCache({
    required MultiSigService multiSigService,
  }) : _multiSigService = multiSigService {
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

  final MultiSigService _multiSigService;

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
    for (final signerAddress in signerAddresses) {
      final addressItems = <MultiSigActionListItem>[];

      // TODO-Roy: Add service route to get txs for multiple addresses
      final pendingTxs = await _multiSigService.getPendingTxs(
        signerAddresses: [signerAddress],
      );

      if (pendingTxs == null) {
        logDebug('Sync failed to get pending txs');
        return;
      }

      final pendingItems = _toSignListItems(pendingTxs, signerAddress);
      addressItems.addAll(pendingItems);

      // TODO-Roy: Add service route to get txs for multiple addresses
      final createdTxs = await _multiSigService.getCreatedTxs(
        signerAddresses: [signerAddress],
      );

      if (createdTxs == null) {
        logDebug('Sync failed to get created txs');
        return;
      }

      for (final tx in createdTxs) {
        if (tx.status == MultiSigStatus.ready && tx.signatures != null) {
          final ref = _main.record(tx.txUuid);
          final db = await _db;
          final result = await ref.get(db);
          if (result != null) {
            final model = _SembastResultData.fromRecord(result);
            final success = await _multiSigService.updateTxResult(
              txUuid: model.txUuid,
              txHash: model.txHash,
              coin: ChainId.toCoin(model.chainId),
            );

            if (success) {
              await ref.delete(db);
            }
          } else {
            final item = _toTransmitListItem(tx, signerAddress);
            addressItems.add(item);
          }
        }
      }

      _actionItemsBySignerAddress[signerAddress] = addressItems;
    }

    _publish();

    if (!_initialized.isCompleted) {
      _initialized.complete();
    }
  }

  Future<void> finalizeTx({
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

    final success = await _multiSigService.updateTxResult(
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
        gasUsed: response.gasUsed.toInt(),
        gasWanted: response.gasWanted.toInt(),
        height: response.height.toInt(),
        txHash: response.txhash,
        fees: fee.amount,
        codespace: response.codespace,
      ),
    );
  }

  MultiSigTransmitActionListItem _toTransmitListItem(
          MultiSigPendingTx tx, String signerAddress) =>
      MultiSigTransmitActionListItem(
        multiSigAddress: tx.multiSigAddress,
        signerAddress: signerAddress,
        label: (c) => tx.txBody.messages
            .map((e) => e.toMessage().toLocalizedName(c))
            .join(', '),
        subLabel: (c) => Strings.of(c).actionListSubLabelActionRequired,
        txBody: tx.txBody,
        fee: tx.fee,
        txUuid: tx.txUuid,
        signatures: tx.signatures!,
      );

  List<MultiSigSignActionListItem> _toSignListItems(
          Iterable<MultiSigPendingTx> items, String signerAddress) =>
      items.map(
        (e) {
          return MultiSigSignActionListItem(
            multiSigAddress: e.multiSigAddress,
            signerAddress: signerAddress,
            label: (c) => e.txBody.messages
                .map((e) => e.toMessage().toLocalizedName(c))
                .join(', '),
            subLabel: (c) => Strings.of(c).actionListSubLabelActionRequired,
            txBody: e.txBody,
            fee: e.fee,
            txUuid: e.txUuid,
          );
        },
      ).toList();

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
  String get txUuid;
}

class MultiSigSignActionListItem implements MultiSigActionListItem {
  MultiSigSignActionListItem({
    required this.multiSigAddress,
    required this.signerAddress,
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
