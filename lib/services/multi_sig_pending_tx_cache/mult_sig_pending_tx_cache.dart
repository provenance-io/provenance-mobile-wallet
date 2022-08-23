import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/mixin/listenable_mixin.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_pending_tx.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_signature.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_status.dart';
import 'package:provenance_wallet/services/multi_sig_service/multi_sig_service.dart';
import 'package:provenance_wallet/util/extensions/generated_message_extension.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigPendingTxCache extends Listenable with ListenableMixin {
  MultiSigPendingTxCache({
    required MultiSigService multiSigService,
  }) : _multiSigService = multiSigService;

  final MultiSigService _multiSigService;

  final items = <MultiSigActionListItem>[];

  final _cache = <String, List<MultiSigActionListItem>>{};

  Future<void> update({
    required List<String> signerAddresses,
  }) async {
    for (final signerAddress in signerAddresses) {
      final addressItems = <MultiSigActionListItem>[];

      // TODO-Roy: Add service route to get txs for multiple addresses
      final pendingTxs = await _multiSigService.getPendingTxs(
        signerAddress: signerAddress,
      );

      final pendingItems = _toSignListItems(pendingTxs, signerAddress);
      addressItems.addAll(pendingItems);

      // TODO-Roy: Add service route to get txs for multiple addresses
      final createdTxs = await _multiSigService.getCreatedTxs(
        signerAddress: signerAddress,
      );
      final createdItems = _toTransmitListItems(
        createdTxs?.where(
            (e) => e.status == MultiSigStatus.ready && e.signatures != null),
        signerAddress,
      );
      addressItems.addAll(createdItems);

      _cache[signerAddress] = addressItems;
    }

    _publish();
  }

  List<MultiSigTransmitActionListItem> _toTransmitListItems(
          Iterable<MultiSigPendingTx>? items, String signerAddress) =>
      items?.map(
        (e) {
          return MultiSigTransmitActionListItem(
            multiSigAddress: e.multiSigAddress,
            signerAddress: signerAddress,
            label: (c) => e.txBody.messages
                .map((e) => e.toMessage().toLocalizedName(c))
                .join(', '),
            subLabel: (c) => Strings.of(c).actionListSubLabelActionRequired,
            txBody: e.txBody,
            fee: e.fee,
            txUuid: e.txUuid,
            signatures: e.signatures!,
          );
        },
      ).toList() ??
      [];

  List<MultiSigSignActionListItem> _toSignListItems(
          Iterable<MultiSigPendingTx>? items, String signerAddress) =>
      items?.map(
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
      ).toList() ??
      [];

  Future<void> remove({
    required List<String> signerAddresses,
  }) async {
    for (final address in signerAddresses) {
      _cache.remove(address);
    }

    _publish();
  }

  void _publish() {
    final updated = _cache.entries.fold<List<MultiSigActionListItem>>(
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

  final String txUuid;

  @override
  final LocalizedString label;

  @override
  final LocalizedString subLabel;

  final List<MultiSigSignature> signatures;
}
