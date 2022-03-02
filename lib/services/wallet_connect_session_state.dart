import 'package:provenance_wallet/services/remote_client_details.dart';
import 'package:provenance_wallet/services/wallet_connect_session_status.dart';

class WalletConnectSessionState {
  WalletConnectSessionState.disconnected()
      : status = WalletConnectSessionStatus.disconnected,
        details = null;

  WalletConnectSessionState.connecting()
      : status = WalletConnectSessionStatus.connecting,
        details = null;

  WalletConnectSessionState.connected(RemoteClientDetails clientDetails)
      : status = WalletConnectSessionStatus.connected,
        details = clientDetails;

  final WalletConnectSessionStatus status;
  final RemoteClientDetails? details;
}
