import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_status.dart';

class WalletConnectSessionState {
  WalletConnectSessionState.disconnected()
      : status = WalletConnectSessionStatus.disconnected,
        details = null;

  WalletConnectSessionState.connecting()
      : status = WalletConnectSessionStatus.connecting,
        details = null;

  WalletConnectSessionState.connected(ClientMeta clientDetails)
      : status = WalletConnectSessionStatus.connected,
        details = clientDetails;

  final WalletConnectSessionStatus status;
  final ClientMeta? details;
}
