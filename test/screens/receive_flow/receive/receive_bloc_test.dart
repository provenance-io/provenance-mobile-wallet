import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provenance_blockchain_wallet/screens/receive_flow/receive/receive_bloc.dart';
import 'package:provenance_blockchain_wallet/services/models/wallet_details.dart';
import 'package:provenance_dart/wallet.dart';

import 'receive_bloc_test.mocks.dart';

@GenerateMocks([ReceiveNavigator])
main() {
  final walletDetails = WalletDetails(
    id: "123",
    address: "Address",
    name: "Name",
    publicKey: "abc123",
    coin: Coin.testNet,
  );

  ReceiveBloc? bloc;
  MockReceiveNavigator? navigator;

  setUp(() {
    navigator = MockReceiveNavigator();
    bloc = ReceiveBloc(walletDetails, navigator!);
  });

  test("state", () async {
    final state = await bloc!.stream.first;

    expect(state.walletAddress, walletDetails.address);
  });
}
