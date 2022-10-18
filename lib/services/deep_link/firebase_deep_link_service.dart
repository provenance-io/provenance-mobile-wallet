import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/config_service/local_config.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/invite_link_util.dart' as util;
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseDeepLinkService implements DeepLinkService {
  FirebaseDeepLinkService();

  final _subscriptions = CompositeSubscription();
  final _link = BehaviorSubject<Uri>(sync: true);
  final _localConfig = get<LocalConfig>();

  @override
  ValueStream<Uri> get link => _link;

  Future<void> init() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
      if (initialLink != null) {
        _link.add(initialLink.link);
      }

      FirebaseDynamicLinks.instance.onLink
          .listen((e) => _link.add(e.link))
          .addTo(_subscriptions);
    } else {
      logDebug(
          'Deep linking not supported on platform: ${Platform.operatingSystem}');
    }
  }

  @override
  Future<String> createInviteLink(String inviteId, Coin coin) async {
    final packageId = _localConfig.packageId;

    final link = util.createInviteLink(inviteId, coin);

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
}
