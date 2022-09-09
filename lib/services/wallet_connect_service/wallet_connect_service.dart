import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/session_action.dart';

import 'wallet_connect_session.dart';
import 'wallet_connect_session_delegate.dart';

typedef WalletConnectionFactory = WalletConnection Function(
  WalletConnectAddress address,
);

abstract class WalletConnectService extends Listenable {
  final sessionEvents = WalletConnectSessionEvents();
  final delegateEvents = WalletConnectSessionDelegateEvents();

  Future<bool> disconnectSession();

  Future<bool> approveSession({
    required SessionAction details,
    required bool allowed,
  });

  Future<bool> connectSession(String accountId, String addressData);

  Future<bool> sendMessageFinish({
    required String requestId,
    required bool allowed,
  });
}
