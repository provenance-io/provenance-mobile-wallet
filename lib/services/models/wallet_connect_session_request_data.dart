import 'package:provenance_dart/wallet_connect.dart';

class WalletConnectSessionRequestData {
  WalletConnectSessionRequestData(
    this.id,
    this.requestId,
    this.data,
  );

  final String id;
  final int requestId;
  final SessionRequestData data;
}
