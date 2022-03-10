import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_bank.dart' as bank;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_bloc.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';

import '../send_flow_test_constants.dart';
import 'send_review_bloc_test.mocks.dart';

final get = GetIt.instance;

const receivingAddress = "ReceivingAddress";

final walletDetails = WalletDetails(
  id: "Id",
  address: "Address",
  name: "Name",
  publicKey:
      "02da92ecc44eef3299e00cdf8f4768d5b606bf8242ff5277e6f07aadd935257a37",
  coin: Coin.testNet,
);

@GenerateMocks([SendReviewNaviagor, WalletService])
void main() {
  MockWalletService? mockWalletService;
  MockSendReviewNaviagor? mockNavigator;
  SendReviewBloc? bloc;

  setUp(() {
    mockNavigator = MockSendReviewNaviagor();

    mockWalletService = MockWalletService();
    when(mockWalletService!.onDispose()).thenAnswer((_) => Future.value());
    when(mockWalletService!.estimate(any, any)).thenAnswer((realInvocation) {
      return Future.value(proto.GasEstimate(100));
    });

    get.registerSingleton<WalletService>(mockWalletService!);

    bloc = SendReviewBloc(
      walletDetails,
      mockWalletService!,
      receivingAddress,
      dollarAsset,
      feeAsset,
      "Some Note",
      mockNavigator!,
    );
  });

  tearDown(() {
    get.unregister<WalletService>();
  });

  test("StateStream", () async {
    expectLater(
      bloc!.stream,
      emitsInOrder(
        [
          predicate((args) {
            final state = args as SendReviewBlocState;
            expect(state.receivingAddress, receivingAddress);
            expect(state.sendingAsset, dollarAsset);
            expect(state.fee, feeAsset);

            return true;
          }),
        ],
      ),
    );
  });

  test("Complete", () {
    bloc!.complete();

    verify(mockNavigator!.complete());
  });

  group("doSend", () {
    test("args", () async {
      when(mockWalletService!.submitTransaction(any, any))
          .thenAnswer((_) => Future.value());
      await bloc!.doSend();

      final captures = verify(mockWalletService!.submitTransaction(
        captureAny,
        walletDetails,
        captureAny,
      )).captured;

      final txBody = captures.first as proto.TxBody;
      expect(txBody.memo, "Some Note");
      expect(txBody.messages.length, 1);

      final estimate = captures.last as proto.GasEstimate;
      expect(estimate.limit, feeAsset.limit.amount.toBigInt().toInt());
      expect(estimate.feeCalculated, predicate((arg) {
        final coins = arg as List<proto.Coin>;
        expect(coins.length, feeAsset.fees.length);

        for (var index = 0; index < coins.length; index++) {
          final fee = feeAsset.fees[index];
          final coin = coins[index];

          expect(fee.denom, coin.denom);
          expect(fee.amount.toString(), coin.amount);
        }

        return true;
      }));

      final msg = txBody.messages[0] as proto.Any;
      final sendMsg = bank.MsgSend.fromBuffer(msg.value);
      expect(sendMsg.fromAddress, walletDetails.address);
      expect(sendMsg.toAddress, receivingAddress);
      expect(sendMsg.amount.length, 1);
      expect(sendMsg.amount[0].denom, dollarAsset.denom);
      expect(sendMsg.amount[0].amount, dollarAsset.amount.toString());
    });
  });
}