import 'wallet_connect_action.dart';
import 'wallet_connect_action_kind.dart';

class SignAction implements WalletConnectAction {
  SignAction({
    required this.id,
    required this.requestId,
    required this.message,
    required this.description,
    required this.address,
  });

  @override
  final String id;

  @override
  final int requestId;

  @override
  WalletConnectActionKind get kind => WalletConnectActionKind.sign;

  final String message;
  final String description;
  final String address;
}
