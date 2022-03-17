import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_bloc.dart';
import 'package:provenance_wallet/services/models/price.dart';
import 'package:provenance_wallet/services/price_service/price_service.dart';
import 'package:provenance_wallet/services/wallet_service/model/wallet_gas_estimate.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_transaction_handler.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';

import '../send_flow_test_constants.dart';
import 'send_amount_bloc_test.mocks.dart';

final get = GetIt.instance;

Matcher throwsExceptionWithText(String msg) {
  return throwsA(predicate((arg) {
    return arg is Exception && arg.toString() == "Exception: $msg";
  }));
}

const feeAmount = WalletGasEstimate(
  20000000,
  1,
);

@GenerateMocks([
  SendAmountBlocNavigator,
  WalletService,
  WalletConnectTransactionHandler,
  PriceService,
])
main() {
  const receivingAddress = "ReceivingAdress";

  SendAmountBloc? bloc;
  MockSendAmountBlocNavigator? mockNavigator;
  MockWalletService? mockWalletService;
  MockWalletConnectTransactionHandler? mockWalletConnectTransactionHandler;
  MockPriceService? mockPriceService;

  setUp(() {
    mockWalletConnectTransactionHandler = MockWalletConnectTransactionHandler();
    when(mockWalletConnectTransactionHandler!.estimateGas(any, any))
        .thenAnswer((_) => Future.value(feeAmount));

    mockPriceService = MockPriceService();
    when(mockPriceService!.getAssetPrices(any))
        .thenAnswer((realInvocation) => Future.value(<Price>[]));

    get.registerSingleton<WalletConnectTransactionHandler>(
      mockWalletConnectTransactionHandler!,
    );

    mockWalletService = MockWalletService();
    get.registerSingleton<MockWalletService>(
      mockWalletService!,
    );

    when(mockWalletService!.onDispose()).thenAnswer((_) => Future.value());
    get.registerSingleton<WalletService>(mockWalletService!);

    mockNavigator = MockSendAmountBlocNavigator();
    bloc = SendAmountBloc(
      walletDetails,
      receivingAddress,
      hashAsset,
      mockPriceService!,
      mockNavigator!,
    );
  });

  tearDown(() {
    get.unregister<WalletService>();
    get.unregister<WalletConnectTransactionHandler>();
    get.unregister<MockWalletService>();
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
          feeAsset.estimate,
          feeAmount.estimate,
        );
        expect(feeAsset.fees.first.denom, "nhash");
        expect(
          feeAsset.fees.first.amount,
          Decimal.fromInt(feeAmount.estimate * feeAmount.baseFee!),
        );
        expect(feeAsset.fees.length, 1);

        return true;
      }));

      return true;
    })));

    bloc!.init();
  });

  test("validateAmount", () {
    expect(bloc!.validateAmount(null), "'' is an invalid amount");
    expect(bloc!.validateAmount(""), "'' is an invalid amount");
    expect(bloc!.validateAmount("abc"), "'abc' is an invalid amount");
    // expect(bloc!.validateAmount("1.1234567890"), "too many decimal places");
    expect(bloc!.validateAmount("100.000000001"), "Insufficient Hash");
    expect(bloc!.validateAmount("1.000000000"), null);
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
        "'' is an invalid amount",
      ),
    );
    expect(
      () => bloc!.showNext("", "abc"),
      throwsExceptionWithText(
        "'abc' is an invalid amount",
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
    expect(feeAsset.estimate, feeAmount.estimate);
    expect(feeAsset.fees.first.denom, "nhash");
    expect(
      feeAsset.fees.first.amount,
      Decimal.fromInt(feeAmount.estimate * feeAmount.baseFee!),
    );
  });
}
