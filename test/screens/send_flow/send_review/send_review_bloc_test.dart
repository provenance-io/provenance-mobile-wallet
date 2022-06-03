import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_bank.dart' as bank;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';

import '../send_flow_test_constants.dart';
import 'send_review_bloc_test.mocks.dart';

final get = GetIt.instance;

const receivingAddress = "ReceivingAddress";

final publicKey = PrivateKey.fromSeed(
  Mnemonic.createSeed(['one']),
  Coin.testNet,
).defaultKey().publicKey;

final accountDetails = BasicAccount(
  id: "Id",
  name: "Name",
  publicKey: publicKey,
);

@GenerateMocks([
  SendReviewNaviagor,
  AccountService,
  TransactionHandler,
])
void main() {
  PrivateKey? privateKey;
  MockAccountService? mockAccountService;
  MockSendReviewNaviagor? mockNavigator;
  MockTransactionHandler? mockTransactionHandler;

  SendReviewBloc? bloc;

  setUp(() {
    final entropy = List.generate(64, (index) => index).toList();
    final phrase = Mnemonic.fromEntropy(entropy);
    final seed = Mnemonic.createSeed(phrase);

    privateKey = PrivateKey.fromSeed(seed, Coin.testNet);
    mockNavigator = MockSendReviewNaviagor();

    mockTransactionHandler = MockTransactionHandler();
    when(mockTransactionHandler!.estimateGas(any, any))
        .thenAnswer((realInvocation) {
      return Future.value(AccountGasEstimate(100, null));
    });

    mockAccountService = MockAccountService();
    when(mockAccountService!.onDispose()).thenAnswer((_) => Future.value());
    when(mockAccountService!.loadKey(any))
        .thenAnswer((_) => Future.value(privateKey!));

    get.registerSingleton<AccountService>(mockAccountService!);

    bloc = SendReviewBloc(
      accountDetails,
      mockTransactionHandler!,
      receivingAddress,
      dollarAsset,
      feeAsset,
      "Some Note",
      mockNavigator!,
    );
  });

  tearDown(() {
    get.unregister<AccountService>();
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
      when(mockTransactionHandler!.executeTransaction(
        any,
        any,
        any,
      )).thenAnswer((_) => Future.value(proto.RawTxResponsePair(
            proto.TxRaw(),
            proto.TxResponse(),
          )));

      await bloc!.doSend();

      final captures = verify(mockTransactionHandler!.executeTransaction(
        captureAny,
        privateKey!,
        captureAny,
      )).captured;

      final txBody = captures.first as proto.TxBody;
      expect(txBody.memo, "Some Note");
      expect(txBody.messages.length, 1);

      final estimate = captures.last as proto.GasEstimate;
      expect(estimate.limit, feeAsset.estimate);
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

      final msg = txBody.messages[0];
      final sendMsg = bank.MsgSend.fromBuffer(msg.value);
      expect(sendMsg.fromAddress, accountDetails.address);
      expect(sendMsg.toAddress, receivingAddress);
      expect(sendMsg.amount.length, 1);
      expect(sendMsg.amount[0].denom, dollarAsset.denom);
      expect(sendMsg.amount[0].amount, dollarAsset.amount.toString());
    });
  });
}
