import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet.dart' as wallet;
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/mixin/listenable_mixin.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
import 'package:provenance_wallet/services/models/service_tx_response.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_pending_tx.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_signature.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_status.dart';
import 'package:provenance_wallet/services/multi_sig_service/multi_sig_service.dart';
import 'package:provenance_wallet/util/extensions/generated_message_extension.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/subjects.dart';

class MultiSigPendingTxCache extends Listenable with ListenableMixin {
  MultiSigPendingTxCache({
    required MultiSigService multiSigService,
  }) : _multiSigService = multiSigService;

  final MultiSigService _multiSigService;

  final items = <MultiSigActionListItem>[];

  final _itemsBySignerAddress = <String, List<MultiSigActionListItem>>{};
  // TODO-Roy: Persist across app restarts
  final _resultsByTxUuid = <String, _TxResultData>{};
  final _initialized = Completer();
  final _response = PublishSubject<ServiceTxResponse>();

  Future<void> get initialized => _initialized.future;
  Stream<ServiceTxResponse> get response => _response;

  Future<void> fetch({
    required List<String> signerAddresses,
  }) async {
    for (final signerAddress in signerAddresses) {
      final addressItems = <MultiSigActionListItem>[];

      // TODO-Roy: Add service route to get txs for multiple addresses
      final pendingTxs = await _multiSigService.getPendingTxs(
        signerAddress: signerAddress,
      );

      if (pendingTxs == null) {
        return;
      }

      final pendingItems = _toSignListItems(pendingTxs, signerAddress);
      addressItems.addAll(pendingItems);

      // TODO-Roy: Add service route to get txs for multiple addresses
      final createdTxs = await _multiSigService.getCreatedTxs(
        signerAddress: signerAddress,
      );

      if (createdTxs == null) {
        return;
      }

      for (final tx in createdTxs) {
        if (tx.status == MultiSigStatus.ready && tx.signatures != null) {
          final result = _resultsByTxUuid[tx.txUuid];
          if (result != null) {
            final success = await _multiSigService.updateTxResult(
              txUuid: result.txUuid,
              txHash: result.txHash,
              coin: result.coin,
            );

            if (success) {
              _resultsByTxUuid.remove(tx.txUuid);
            }
          } else {
            final item = _toTransmitListItem(tx, signerAddress);
            addressItems.add(item);
          }
        }
      }

      _itemsBySignerAddress[signerAddress] = addressItems;
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
    _resultsByTxUuid[txUuid] = _TxResultData(
      txUuid: txUuid,
      txHash: response.txhash,
      coin: coin,
    );

    final success = await _multiSigService.updateTxResult(
      txUuid: txUuid,
      txHash: response.txhash,
      coin: coin,
    );

    if (success) {
      _resultsByTxUuid.remove(txUuid);
    }

    _itemsBySignerAddress[signerAddress]
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
      _itemsBySignerAddress.remove(address);
    }

    _publish();
  }

  void _publish() {
    final updated = _itemsBySignerAddress.entries
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

class _TxResultData {
  _TxResultData({
    required this.txUuid,
    required this.txHash,
    required this.coin,
  });

  final String txUuid;
  final String txHash;
  final wallet.Coin coin;
}
