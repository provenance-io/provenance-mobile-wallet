import 'package:provenance_dart/wallet_connect.dart';

WalletConnectAddress? getWalletConnectAddress(Uri uri) {
  WalletConnectAddress? address;
  // queryParameters values are already decoded automatically
  final data = uri.queryParameters['data'];
  if (data != null) {
    final addressStr = Uri.decodeComponent(data);
    address = WalletConnectAddress.create(addressStr);
  }

  return address;
}

bool isValidWalletConnectAddress(String walletConnectAddress) {
  return WalletConnectAddress.create(walletConnectAddress) != null;
}
