import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/wallet_connect_session_state.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/wallet_connect_session_status.dart';

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
