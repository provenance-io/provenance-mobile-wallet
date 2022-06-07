import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/receive_flow/receive/receive_bloc.dart';
import 'package:provenance_wallet/services/models/account_details.dart';

main() {
  final walletDetails = AccountDetails(
    id: "123",
    address: "Address",
    name: "Name",
    publicKey: "abc123",
    coin: Coin.testNet,
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
