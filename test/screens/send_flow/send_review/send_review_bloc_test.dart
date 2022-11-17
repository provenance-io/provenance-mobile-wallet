import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_cosmos_bank_v1beta1.dart' as bank;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/gas_fee_estimate.dart';
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/util/constants.dart';

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
  TxQueueService,
])
void main() {
  PrivateKey? privateKey;
  MockAccountService? mockAccountService;
  MockSendReviewNaviagor? mockNavigator;
  MockTxQueueService? mockTxQueueService;

  SendReviewBloc? bloc;

  setUp(() {
    final entropy = List.generate(64, (index) => index).toList();
    final phrase = Mnemonic.fromEntropy(entropy);
    final seed = Mnemonic.createSeed(phrase);

    privateKey = PrivateKey.fromSeed(seed, Coin.testNet);
    mockNavigator = MockSendReviewNaviagor();

    mockTxQueueService = MockTxQueueService();
    when(mockTxQueueService!.estimateGas(
            txBody: anyNamed('txBody'), account: anyNamed('account')))
        .thenAnswer((_) {
      return Future.value(GasFeeEstimate.single(
          units: 100, denom: nHashDenom, amountPerUnit: 10));
    });

    mockAccountService = MockAccountService();
    when(mockAccountService!.onDispose()).thenAnswer((_) => Future.value());
    when(mockAccountService!.loadKey(any, any))
        .thenAnswer((_) => Future.value(privateKey!));

    get.registerSingleton<AccountService>(mockAccountService!);

    bloc = SendReviewBloc(
      accountDetails,
      mockTxQueueService!,
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
      when(mockTxQueueService!.scheduleTx(
        txBody: anyNamed('txBody'),
        account: anyNamed('account'),
        gasEstimate: anyNamed('gasEstimate'),
      )).thenAnswer(
        (_) async => ExecutedTx(
          result: TxResult(
            body: proto.TxBody(),
            response: proto.RawTxResponsePair(
              proto.TxRaw(),
              proto.TxResponse(),
            ),
            fee: proto.Fee(),
          ),
        ),
      );

      await bloc!.doSend();

      final captures = verify(mockTxQueueService!.scheduleTx(
        txBody: captureAnyNamed('txBody'),
        account: captureAnyNamed('account'),
        gasEstimate: captureAnyNamed('gasEstimate'),
      )).captured;

      final txBody = captures.first as proto.TxBody;
      expect(txBody.memo, "Some Note");
      expect(txBody.messages.length, 1);

      final estimate = captures.last as GasFeeEstimate;
      expect(estimate, feeAsset.estimate);

      final msg = txBody.messages[0];
      final sendMsg = bank.MsgSend.fromBuffer(msg.value);
      expect(sendMsg.fromAddress, accountDetails.publicKey.address);
      expect(sendMsg.toAddress, receivingAddress);
      expect(sendMsg.amount.length, 1);
      expect(sendMsg.amount[0].denom, dollarAsset.denom);
      expect(sendMsg.amount[0].amount, dollarAsset.amount.toString());
    });
  });
}
