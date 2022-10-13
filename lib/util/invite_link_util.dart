import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:http/http.dart' as http;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/config_service/local_config.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

const _origin = 'https://provenance.io';
const _segment = 'invite';
const _paramInviteId = 'inviteId';
const _paramChainId = 'chainId';

Future<String> createDynamicInviteLink(String inviteId, Coin coin) async {
  final localConfig = get<LocalConfig>();
  final packageId = localConfig.packageId;

  final link = createInviteLink(inviteId, coin);

  final params = DynamicLinkParameters(
    link: Uri.parse(link),
    uriPrefix: 'https://provenancewallet.page.link',
    androidParameters: AndroidParameters(
      packageName: packageId,
    ),
    iosParameters: IOSParameters(
      bundleId: packageId,
    ),
  );

  final dynamicLink =
      await FirebaseDynamicLinks.instance.buildShortLink(params);

  return dynamicLink.shortUrl.toString();
}

@visibleForTesting
String createInviteLink(String inviteId, Coin coin) {
  final chainId = ChainId.forCoin(coin);

  return '$_origin/$_segment?$_paramInviteId=$inviteId&$_paramChainId=$chainId';
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
      coin = ChainId.toCoin(chainId);
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

Future<String?> tryFollowRedirect(String? uri) async {
  if (uri == null) {
    return null;
  }

  var result = Uri.tryParse(uri);
  if (result == null) {
    return null;
  }

  final baseClient = http.Client();

  try {
    final request = http.Request('Get', result)..followRedirects = false;

    final response = await baseClient.send(request);
    final location = response.headers['location'];
    if (location != null) {
      result = Uri.tryParse(location);
    }
  } on Exception catch (e) {
    Log.instance.error(
      'Failed to follow redirect',
      tag: 'invite_link_util',
      error: e,
    );
  } finally {
    baseClient.close();
  }

  return result.toString();
}

class InviteLinkData {
  InviteLinkData({
    required this.inviteId,
    required this.coin,
  });

  final String inviteId;
  final Coin coin;
}
