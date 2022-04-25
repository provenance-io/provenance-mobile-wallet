import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_blockchain_wallet/services/wallet_service/wallet_connect_session_state.dart';
import 'package:provenance_blockchain_wallet/services/wallet_service/wallet_connect_session_status.dart';
import 'package:provenance_dart/wallet_connect.dart';

main() {
  test("disconnected", () {
    final session = WalletConnectSessionState.disconnected();
    expect(session.details, null);
    expect(session.status, WalletConnectSessionStatus.disconnected);
  });

  test("connecting", () {
    final session = WalletConnectSessionState.connecting();
    expect(session.details, null);
    expect(session.status, WalletConnectSessionStatus.connecting);
  });

  test("connected", () {
    final meta = ClientMeta();
    final session = WalletConnectSessionState.connected(meta);
    expect(session.details, meta);
    expect(session.status, WalletConnectSessionStatus.connected);
  });
}
