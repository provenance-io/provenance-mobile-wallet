import 'package:provenance_dart/wallet_connect.dart';

import 'wallet_connect_action.dart';
import 'wallet_connect_action_kind.dart';

class SessionAction implements WalletConnectAction {
  SessionAction(
    this.id,
    this.walletConnectRequestId,
    this.data,
  );

  @override
  final String id;

  @override
  final int walletConnectRequestId;

  @override
  WalletConnectActionKind get kind => WalletConnectActionKind.session;

  final SessionRequestData data;
}
