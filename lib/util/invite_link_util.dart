import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:provenance_dart/wallet.dart';

const _origin = 'https://provenance.io';
const _segment = 'invite';
const _paramInviteId = 'inviteId';
const _paramChainId = 'chainId';

String createInviteLink(String inviteId, Coin coin) {
  return '$_origin/$_segment?$_paramInviteId=$inviteId&$_paramChainId=${coin.chainId}';
}

InviteLinkData? parseInviteLinkData(String inviteLink) {
  InviteLinkData? data;

  final uri = Uri.tryParse(inviteLink);
  final origin = uri?.origin;
  final segment = uri?.pathSegments.firstOrNull;
  final query = uri?.queryParameters;
  final inviteId = query?[_paramInviteId];
  final chainId = query?[_paramChainId];

  if (origin == _origin &&
      segment == _segment &&
      inviteId != null &&
      chainId != null) {
    Coin? coin;

    try {
      coin = Coin.forChainId(chainId);
    } catch (_) {
      log('Invalid chain id: $chainId');
    }

    if (coin != null) {
      data = InviteLinkData(
        inviteId: inviteId,
        coin: coin,
      );
    }
  }

  return data;
}

class InviteLinkData {
  InviteLinkData({
    required this.inviteId,
    required this.coin,
  });

  final String inviteId;
  final Coin coin;
}
