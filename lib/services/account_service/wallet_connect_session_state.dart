import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_status.dart';

class WalletConnectSessionState {
  const WalletConnectSessionState.disconnected()
      : status = WalletConnectSessionStatus.disconnected,
        details = null;

  const WalletConnectSessionState.connecting()
      : status = WalletConnectSessionStatus.connecting,
        details = null;

  WalletConnectSessionState.connected(ClientMeta clientDetails)
      : status = WalletConnectSessionStatus.connected,
        details = clientDetails;

  final WalletConnectSessionStatus status;
  final ClientMeta? details;
}
