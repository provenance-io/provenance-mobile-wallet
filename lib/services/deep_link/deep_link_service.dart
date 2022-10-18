import 'package:provenance_dart/wallet.dart';
import 'package:rxdart/rxdart.dart';

abstract class DeepLinkService {
  ValueStream<Uri> get link;

  Future<String> createInviteLink(String inviteId, Coin coin);
}
