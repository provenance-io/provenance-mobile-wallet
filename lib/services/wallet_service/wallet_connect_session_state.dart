import 'package:provenance_blockchain_wallet/services/wallet_service/wallet_connect_session_status.dart';
import 'package:provenance_dart/wallet_connect.dart';

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
