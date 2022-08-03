import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/extension/wallet_connect_address_helper.dart';

const walletConnectAddress =
    "wc:c2572162-bc23-442c-95c7-a4b6403331f4@1?bridge=wss%3A%2F%2Ftest.figure.tech%2Fservice-wallet-connect-bridge%2Fws%2Fexternal&key=c90653342c66a002944cff439239b79cc6fdde42b61a10c6d1e8d05506bd92bf";

main() {
  test('fullUriString generates original address', () {
    final address = WalletConnectAddress.create(walletConnectAddress)!;

    expect(address.fullUriString, walletConnectAddress);
  });

  test('fullUri generates original address', () {
    final address = WalletConnectAddress.create(walletConnectAddress)!;

    expect(address.fullUri, Uri.parse(walletConnectAddress));
  });
}
