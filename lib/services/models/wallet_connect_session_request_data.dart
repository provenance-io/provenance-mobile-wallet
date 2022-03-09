import 'package:provenance_dart/wallet_connect.dart';

class WalletConnectSessionRequestData {
  WalletConnectSessionRequestData(
    this.id,
    this.data,
  );

  final String id;
  final SessionRequestData data;
}
