import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_bloc.dart';
import 'package:provenance_wallet/services/wallet_service.dart';
import '../send_flow_test_constants.dart';
import 'send_amount_bloc_test.mocks.dart';

final get = GetIt.instance;

Matcher throwsExceptionWithText(String msg) {
  return throwsA(predicate((arg) {
    return arg is Exception && arg.toString() == "Exception: $msg";
  }));
}

<<<<<<< HEAD
const feeAmount = 20000000;

@GenerateMocks([ SendAmountBlocNavigator, WalletService, ])
main() {
=======
@GenerateMocks([SendAmountBlocNavigator])
main() {
  final asset = SendAsset(
    "Hash",
    "100",
    "200",
    "http://test.com",
  );
>>>>>>> develop
  const receivingAddress = "ReceivingAdress";

  SendAmountBloc? bloc;
  MockSendAmountBlocNavigator? mockNavigator;
  MockWalletService? mockWalletService;

  setUp(() {
    mockWalletService = MockWalletService();
    when(mockWalletService!.estimate(any, any)).thenAnswer((_) => Future.value(feeAmount));

    get.registerSingleton<WalletService>(mockWalletService!);

    mockNavigator = MockSendAmountBlocNavigator();
<<<<<<< HEAD
    bloc = SendAmountBloc(walletDetails, receivingAddress, hashAsset, mockNavigator!,);
  });

  tearDown(() {
    get.unregister<WalletService>();
=======
    bloc = SendAmountBloc(
      receivingAddress,
      asset,
      mockNavigator!,
    );
>>>>>>> develop
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
        final feeAsset = arg as SendAsset;
        expect(feeAsset.amount, Decimal.fromInt(feeAmount));
        expect(feeAsset.denom, "nhash");

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

<<<<<<< HEAD
    expect(() => bloc!.showNext("", ""),  throwsExceptionWithText("'' is an invalid amount"));
    expect(() => bloc!.showNext("","abc"), throwsExceptionWithText("'abc' is an invalid amount"));
    // expect(() => bloc!.showNext("","1.1234567890"), throwsExceptionWithText("too many decimal places"));
    expect(() => bloc!.showNext("","100.000000001"), throwsExceptionWithText("Insufficient Hash"));
=======
    expect(
      () => bloc!.showNext("", ""),
      throwsExceptionWithText("'' is an invalid amount"),
    );
    expect(
      () => bloc!.showNext("", "abc"),
      throwsExceptionWithText("'abc' is an invalid amount"),
    );
    expect(
      () => bloc!.showNext("", "1.1234567890"),
      throwsExceptionWithText("too many decimal places"),
    );
    expect(
      () => bloc!.showNext("", "100.000000001"),
      throwsExceptionWithText("Insufficient Hash"),
    );
>>>>>>> develop
  });

  test("showNext - invoke navigator", () async {
    bloc!.init();
    await bloc!.stream.first;

<<<<<<< HEAD
    bloc!.showNext("A Note", "1.1");
    
    final captures = verify(mockNavigator!.showReviewSend(captureAny, captureAny, "A Note",)).captured;

    final amountAsset = captures[0] as SendAsset;
    final feeAsset = captures[1] as SendAsset;

    expect(amountAsset.amount, Decimal.parse("110"));
    expect(amountAsset.denom, hashAsset.denom);
    expect(feeAsset.amount, Decimal.fromInt(feeAmount));
    expect(feeAsset.denom, "nhash");
=======
    bloc!.showNext("A Note", "75.01");
    verify(mockNavigator!.showReviewSend(
      "75.01",
      "0.02 Hash",
      "A Note",
    ));
>>>>>>> develop
  });
}
