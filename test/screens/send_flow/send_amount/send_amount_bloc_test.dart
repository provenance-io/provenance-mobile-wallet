import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_wallet/gas_fee_estimate.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/price.dart';
import 'package:provenance_wallet/services/price_client/price_service.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/util/constants.dart';

import '../send_flow_test_constants.dart';
import 'send_amount_bloc_test.mocks.dart';

final get = GetIt.instance;

Matcher throwsExceptionWithText(String msg) {
  return throwsA(predicate((arg) {
    return arg is Exception && arg.toString() == "Exception: $msg";
  }));
}

final feeEstimate = GasFeeEstimate.single(
  units: 20000000,
  denom: nHashDenom,
  amountPerUnit: 1,
);

@GenerateMocks([
  SendAmountBlocNavigator,
  AccountService,
  TxQueueService,
  PriceClient,
])
main() {
  const receivingAddress = "ReceivingAdress";
  const requiredString = "Required";

  SendAmountBloc? bloc;
  MockSendAmountBlocNavigator? mockNavigator;
  MockAccountService? mockAccountService;
  MockTxQueueService? mockTxQueueService;
  MockPriceClient? mockPriceClient;

  setUp(() {
    mockTxQueueService = MockTxQueueService();
    when(mockTxQueueService!.estimateGas(
            txBody: anyNamed('txBody'), account: anyNamed('account')))
        .thenAnswer((_) => Future.value(feeEstimate));

    mockPriceClient = MockPriceClient();
    when(mockPriceClient!.getAssetPrices(any, any))
        .thenAnswer((realInvocation) => Future.value(<Price>[]));

    get.registerSingleton<TxQueueService>(
      mockTxQueueService!,
    );

    mockAccountService = MockAccountService();
    get.registerSingleton<MockAccountService>(
      mockAccountService!,
    );

    when(mockAccountService!.onDispose()).thenAnswer((_) => Future.value());
    get.registerSingleton<AccountService>(mockAccountService!);

    mockNavigator = MockSendAmountBlocNavigator();
    bloc = SendAmountBloc(
      walletDetails,
      receivingAddress,
      hashAsset,
      mockPriceClient!,
      mockNavigator!,
      gasEstimateNotReadyString: "The estimated fee is not ready",
      insufficientString: "Insufficient",
      requiredString: requiredString,
      tooManyDecimalPlacesString: "too many decimal places",
    );
  });

  tearDown(() {
    get.unregister<AccountService>();
    get.unregister<TxQueueService>();
    get.unregister<MockAccountService>();
  });

  test("properties", () {
    expect(bloc!.asset, hashAsset);
    expect(bloc!.receivingAddress, receivingAddress);
    expect(bloc!.stream, isNotNull);
  });

  test("init", () async {
    expectLater(bloc!.stream, emits(predicate((arg) {
      final state = arg as SendAmountBlocState;
      expect(state.transactionFees, predicate((arg) {
        final feeAsset = arg as MultiSendAsset;
        expect(
          feeAsset.estimate.units,
          feeEstimate.units,
        );
        expect(feeAsset.assets.first.denom, nHashDenom);
        expect(
          feeAsset.assets.first.amount,
          Decimal.parse(feeEstimate.amount.first.amount),
        );
        expect(feeAsset.assets.length, 1);

        return true;
      }));

      return true;
    })));

    bloc!.init();
  });

  test("validateAmount", () {
    expect(bloc!.validateAmount(null), requiredString);
    expect(bloc!.validateAmount(""), requiredString);
    expect(bloc!.validateAmount("abc"), requiredString);
    expect(bloc!.validateAmount("1.1234567890"), "too many decimal places");
    expect(bloc!.validateAmount("100.000000001"), "Insufficient Hash");
    expect(bloc!.validateAmount("1.00"), null);
  });

  test("showNext - validation errors", () async {
    expect(
      () => bloc!.showNext("", ""),
      throwsExceptionWithText("The estimated fee is not ready"),
    );

    bloc!.init();
    await bloc!.stream.first; // wait for the fee to download

    expect(
      () => bloc!.showNext("", ""),
      throwsExceptionWithText(
        requiredString,
      ),
    );
    expect(
      () => bloc!.showNext("", "abc"),
      throwsExceptionWithText(
        requiredString,
      ),
    );
    // expect(() => bloc!.showNext("","1.1234567890"), throwsExceptionWithText("too many decimal places"));
    expect(
      () => bloc!.showNext("", "100.000000001"),
      throwsExceptionWithText(
        "Insufficient Hash",
      ),
    );
  });

  test("showNext - invoke navigator", () async {
    bloc!.init();
    await bloc!.stream.first;

    bloc!.showNext("A Note", "1.1");

    final captures = verify(mockNavigator!.showReviewSend(
      captureAny,
      captureAny,
      "A Note",
    )).captured;

    final amountAsset = captures[0] as SendAsset;
    final feeAsset = captures[1] as MultiSendAsset;

    expect(amountAsset.amount, Decimal.parse("110"));
    expect(amountAsset.denom, hashAsset.denom);
    expect(feeAsset.estimate.units, feeEstimate.units);
    expect(feeAsset.assets.first.denom, nHashDenom);
    expect(
      feeAsset.assets.first.amount,
      Decimal.parse(feeEstimate.amount.first.amount),
    );
  });
}
