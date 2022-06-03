import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/receive_flow/receive/receive_bloc.dart';
import 'package:provenance_wallet/services/models/account_details.dart';

main() {
  final publicKey = PrivateKey.fromSeed(
    Mnemonic.createSeed(['one']),
    Coin.testNet,
  ).defaultKey().publicKey;

  final walletDetails = AccountDetails(
    id: "123",
    name: "Name",
    publicKey: publicKey,
  );

  ReceiveBloc? bloc;

  setUp(() {
    bloc = ReceiveBloc(walletDetails);
  });

  test("state", () async {
    final state = await bloc!.stream.first;

    expect(state.accountAddress, walletDetails.address);
  });
}
