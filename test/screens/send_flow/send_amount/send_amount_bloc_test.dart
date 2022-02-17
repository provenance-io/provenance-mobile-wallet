import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_bloc.dart';
import 'send_amount_bloc_test.mocks.dart';

Matcher throwsExceptionWithText(String msg) {
  return throwsA(predicate((arg) {
    return arg is Exception &&
            arg.toString() == "Exception: $msg";
  }));
}

@GenerateMocks([ SendAmountBlocNavigator ])
main() {
  final asset = SendAsset("Hash", "100", "200", "http://test.com");
  final receivingAddress = "ReceivingAdress";

  SendAmountBloc? bloc;
  MockSendAmountBlocNavigator? mockNavigator;

  setUp(() {
    mockNavigator = MockSendAmountBlocNavigator();
    bloc = SendAmountBloc(receivingAddress, asset, mockNavigator!);
  });

  test("properties", () {
    expect(bloc!.asset, asset);
    expect(bloc!.receivingAddress, receivingAddress);
    expect(bloc!.stream, isNotNull);
  });

  test("init", () async {
    expectLater(bloc!.stream, emits(predicate((arg) {
      final state = arg as SendAmountBlocState;
      expect(state.transactionFees, "0.02 Hash");

      return true;
    })));

    bloc!.init();
  });

  test("validateAmount", () {
    expect(bloc!.validateAmount(null), "'' is an invalid amount");
    expect(bloc!.validateAmount(""), "'' is an invalid amount");
    expect(bloc!.validateAmount("abc"), "'abc' is an invalid amount");
    expect(bloc!.validateAmount("1.1234567890"), "too many decimal places");
    expect(bloc!.validateAmount("100.000000001"), "Insufficient Hash");
    expect(bloc!.validateAmount("100.000000000"), null);
  });

  test("showNext - validation errors", () async {
    expect(() => bloc!.showNext("", ""),  throwsExceptionWithText("The estimated fee is not ready"));

    bloc!.init();
    await bloc!.stream.first; // wait for the fee to download

    expect(() => bloc!.showNext("", ""),  throwsExceptionWithText("'' is an invalid amount"));
    expect(() => bloc!.showNext("","abc"), throwsExceptionWithText("'abc' is an invalid amount"));
    expect(() => bloc!.showNext("","1.1234567890"), throwsExceptionWithText("too many decimal places"));
    expect(() => bloc!.showNext("","100.000000001"), throwsExceptionWithText("Insufficient Hash"));
  });

  test("showNext - invoke navigator", () async {
    bloc!.init();
    await bloc!.stream.first;

    bloc!.showNext("A Note", "75.01");
    verify(mockNavigator!.showReviewSend("75.01", "0.02 Hash", "A Note"));
  });
}