import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/mixin/listenable_mixin.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
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
    for (final address in signerAddresses) {
      final txs = await _multiSigService.getPendingTxs(
        signerAddress: address,
      );
      if (txs != null) {
        final items = txs.map(
          (e) {
            return MultiSigActionListItem(
              address: e.accountAddress,
              label: (c) => e.txBody.messages
                  .map((e) => e.toMessage().toLocalizedName(c))
                  .join(', '),
              sublabel: (c) => Strings.of(c).actionListSubLabelActionRequired,
              txBody: e.txBody,
              txUuid: e.txUuid,
            );
          },
        ).toList();

        _cache[address] = items;
      }
    }

    _publish();
  }

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

class MultiSigActionListItem extends ActionListItem {
  MultiSigActionListItem({
    required this.address,
    required LocalizedString label,
    required LocalizedString sublabel,
    required this.txBody,
    required this.txUuid,
  }) : super(
          label: label,
          subLabel: sublabel,
        );

  final String address;
  final TxBody txBody;
  final String txUuid;
}
