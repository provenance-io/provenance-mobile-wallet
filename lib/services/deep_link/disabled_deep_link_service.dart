import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/util/invite_link_util.dart' as util;
import 'package:rxdart/rxdart.dart';

class DisabledDeepLinkService implements DeepLinkService {
  @override
  ValueStream<Uri> get link => BehaviorSubject();

  @override
  Future<String> createInviteLink(String inviteId, Coin coin) async =>
      util.createInviteLink(inviteId, coin);
}
