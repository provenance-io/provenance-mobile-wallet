import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_autosizing_text.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_bloc.dart';
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_screen.dart';

import '../send_flow_test_constants.dart';
import 'send_amount_screen_test.mocks.dart';

final get = GetIt.instance;

@GenerateMocks([SendAmountBloc])
main() {
  StreamController<SendAmountBlocState>? _streamController;

  MockSendAmountBloc? mockBloc;

  setUp(() {
    _streamController = StreamController<SendAmountBlocState>();

    mockBloc = MockSendAmountBloc();
    when(mockBloc!.validateAmount(any)).thenReturn(null);
    when(mockBloc!.asset).thenReturn(hashAsset);
    when(mockBloc!.stream).thenAnswer((_) => _streamController!.stream);
    when(mockBloc!.onDispose()).thenAnswer((_) => Future.value());

    get.registerSingleton<SendAmountBloc>(mockBloc!);
  });

  tearDown(() {
    get.unregister<SendAmountBloc>();
    _streamController!.close();
  });

  group("SendAmountScreen", () {
    Future<void> _build(WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Material(
            child: SendAmountScreen(),
          ),
        ),
      );
    }

    testWidgets("Contents", (tester) async {
      await _build(tester);

      expect(find.byType(SendAmountPage), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text("Send Amount"),
        ),
        findsOneWidget,
      );
    });
  });

  group("SendAmountPage", () {
    Future<void> _build(WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Material(
            child: SendAmountPage(),
          ),
        ),
      );
    }

    testWidgets("Contents", (tester) async {
      await _build(tester);

      final iconFind = find.byType(SvgPicture);
      expect(iconFind, findsOneWidget);

      final textAmountFind = find.byType(TextFormField);
      final textAmount = tester.widget<TextFormField>(textAmountFind);
      expect(textAmount.autovalidateMode, AutovalidateMode.onUserInteraction);

      expect(
        find.text(
          "${hashAsset.displayAmount} ${hashAsset.displayDenom} available",
        ),
        findsOneWidget,
      );

      final buttonFind = find.byType(PwButton);
      expect(buttonFind, findsOneWidget);
    });

    testWidgets("Contents - fee", (tester) async {
      await _build(tester);

      var feeRowFind = find.byKey(ValueKey("FeeRow"));
      expect(
        find.descendant(of: feeRowFind, matching: find.text("Transaction")),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: feeRowFind,
          matching: find.text("Acquiring Estimate"),
        ),
        findsOneWidget,
      );

      _streamController!.add(SendAmountBlocState(feeAsset));
      await tester.pumpAndSettle();

      feeRowFind = find.byKey(ValueKey("FeeRow"));
      expect(
        find.descendant(of: feeRowFind, matching: find.text("Transaction")),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: feeRowFind,
          matching: find.text(feeAsset.displayAmount),
        ),
        findsOneWidget,
      );
    });

    testWidgets("disable next button until fee loads", (tester) async {
      await _build(tester);

      var buttonFind = find.byType(PwButton);
      var button = tester.widget<PwButton>(buttonFind);
      expect(button.enabled, false);

      _streamController!.add(SendAmountBlocState(feeAsset));

      await tester.pumpAndSettle();
      buttonFind = find.byType(PwButton);
      button = tester.widget<PwButton>(buttonFind);
      expect(button.enabled, true);
    });

    testWidgets("next button invokes bloc", (tester) async {
      when(mockBloc!.showNext(any, any)).thenAnswer((_) => Future.value());
      _streamController!.add(SendAmountBlocState(feeAsset));
      await _build(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), "1.23");
      await tester.enterText(find.byKey(ValueKey("NoteRow")), "SomeNote");

      var buttonFind = find.byType(PwButton);
      await tester.tap(buttonFind);
      verify(mockBloc!.showNext("SomeNote", "1.23"));
    });

    testWidgets("next button - error", (tester) async {
      final ex = Exception("Next Error");
      when(mockBloc!.showNext(any, any)).thenAnswer((_) => Future.error(ex));
      _streamController!.add(SendAmountBlocState(feeAsset));
      await _build(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), "1.23");
      await tester.enterText(find.byKey(ValueKey("NoteRow")), "SomeNote");

      var buttonFind = find.byType(PwButton);
      await tester.tap(buttonFind);
      await tester.pumpAndSettle();

      final dialogFind = find.byType(ErrorDialog);
      expect(dialogFind, findsOneWidget);

      final dialog = tester.widget<ErrorDialog>(dialogFind);
      expect(dialog.error, "Exception: Next Error");
    });

    testWidgets("Dollar amount of sent", (tester) async {
      await _build(tester);
      var dollarValueSentFind = find.byKey(ValueKey("DollarValueSent"));
      expect(
        tester.widget<PwAutoSizingText>(dollarValueSentFind).data,
        "",
      );

      final textFormFind = find.byType(TextFormField);
      await tester
          .enterText(textFormFind, "1")
          .then((_) => tester.pumpAndSettle());

      expect(
        tester.widget<PwAutoSizingText>(dollarValueSentFind).data,
        hashAsset
            .copyWith(
              amount: Decimal.fromInt(1) *
                  Decimal.fromInt(10).pow(hashAsset.exponent),
            )
            .displayFiatAmount,
      );

      await tester
          .enterText(textFormFind, ".5")
          .then((_) => tester.pumpAndSettle());

      expect(
        tester.widget<PwAutoSizingText>(dollarValueSentFind).data,
        hashAsset
            .copyWith(
              amount: Decimal.parse(".5") *
                  Decimal.fromInt(10).pow(hashAsset.exponent),
            )
            .displayFiatAmount,
      );
    });
  });

  group("DecimalPointFormatter", () {
    final oldNumber = TextEditingValue(text: "123.44");

    test("assertFails", () {
      expect(() => DecimalPointFormatter(-1), throwsAssertionError);
    });

    test("no decimal places", () {
      final newNumber = TextEditingValue(text: "900");

      final formatter = DecimalPointFormatter(2);

      expect(
        formatter.formatEditUpdate(
          oldNumber,
          newNumber,
        ),
        newNumber,
      );
    });

    test("at limit decimal places", () {
      final newNumber = TextEditingValue(text: "900.00");

      final formatter = DecimalPointFormatter(2);

      expect(
        formatter.formatEditUpdate(
          oldNumber,
          newNumber,
        ),
        newNumber,
      );
    });

    test("too many decimal places", () {
      final newNumber = TextEditingValue(text: "900.001");

      final formatter = DecimalPointFormatter(2);

      expect(
        formatter.formatEditUpdate(
          oldNumber,
          newNumber,
        ),
        oldNumber,
      );
    });
  });
}
