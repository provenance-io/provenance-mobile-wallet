import 'package:provenance_wallet/services/wallet_connect_service/models/wallet_connect_action_kind.dart';

abstract class WalletConnectAction {
  WalletConnectAction._();

  String get id;
  int get requestId;
  WalletConnectActionKind get kind;
}
