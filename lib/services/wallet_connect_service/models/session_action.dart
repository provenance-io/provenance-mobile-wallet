import 'package:provenance_dart/wallet_connect.dart';

import 'wallet_connect_action.dart';
import 'wallet_connect_action_kind.dart';

class SessionAction implements WalletConnectAction {
  SessionAction(
    this.id,
    this.walletConnectId,
    this.data,
  );

  @override
  final String id;

  @override
  final int walletConnectId;

  @override
  WalletConnectActionKind get kind => WalletConnectActionKind.session;

  final SessionRequestData data;
}
