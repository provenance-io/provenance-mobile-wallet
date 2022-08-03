import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';

typedef WalletConnectionFactory = WalletConnection Function(
  WalletConnectAddress address,
);

abstract class WalletConnectService extends Listenable {
  final sessionEvents = WalletConnectSessionEvents();
  final delegateEvents = WalletConnectSessionDelegateEvents();

  Future<bool> disconnectSession();

  Future<bool> approveSession({
    required WalletConnectSessionRequestData details,
    required bool allowed,
  });

  Future<bool> connectSession(String accountId, String addressData);

  Future<bool> signTransactionFinish({
    required String requestId,
    required bool allowed,
  });

  Future<bool> sendMessageFinish({
    required String requestId,
    required bool allowed,
  });
}
