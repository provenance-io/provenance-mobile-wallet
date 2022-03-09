import 'package:provenance_dart/wallet_connect.dart';

class WalletConnectSessionRestoreData {
  WalletConnectSessionRestoreData(
    this.clientMeta,
    this.data,
  );

  final ClientMeta clientMeta;
  final SessionRestoreData data;
}
