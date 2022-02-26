import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_bloc.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_screen.dart';
import 'package:provenance_wallet/screens/send_flow/send_flow.dart';

final get = GetIt.instance;

main() {
  SendFlowState? state;
  Future<void> _build(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SendFlow(),
        ),
      ),
    );

    await tester
        .pump(Duration(milliseconds: 600)); // allow simulation timer to elapse.
    state = tester.allStates.firstWhere((element) => element is SendFlowState)
        as SendFlowState;
  }

  testWidgets("Contents", (tester) async {
    await _build(tester);

    expect(find.byType(SendScreen), findsOneWidget);
  });

  testWidgets("createStartPage", (tester) async {
    await _build(tester);

    expect(state!.createStartPage() is SendScreen, true);
  });

  group("SendBlocNavigator", () {
    // fails due to not being able to load images
    // testWidgets("ScanAddress", (tester) async {
    //   await _build(tester);
    //   state!.scanAddress();
    //   await tester.pumpAndSettle();
    //
    //   expect(find.byType(QRCodeScanner), findsOneWidget);
    // });

    testWidgets("showAllRecentSends", (tester) async {
      await _build(tester);
      state!.showAllRecentSends();
      await tester.pumpAndSettle();

      final dialogFind = find.byType(ErrorDialog);
      expect(dialogFind, findsOneWidget);
      expect(
        find.descendant(
          of: dialogFind,
          matching: find.text("Not Implemented"),
        ),
        findsOneWidget,
      );
    });

    testWidgets("showRecentSendDetails", (tester) async {
      final recentAddress = RecentAddress("A", DateTime.now());
      await _build(tester);
      state!.showRecentSendDetails(recentAddress);
      await tester.pumpAndSettle();

      final dialogFind = find.byType(ErrorDialog);
      expect(dialogFind, findsOneWidget);
      expect(
        find.descendant(
          of: dialogFind,
          matching: find.text("Not Implemented"),
        ),
        findsOneWidget,
      );
    });
    //
    // testWidgets("showSelectAmount", (tester) async {
    //   final asset = SendAsset("Hash", "100", "200", "http://test");
    //   await _build(tester);
    //
    //   state!.showSelectAmount("Address", asset);
    //   await tester.pumpAndSettle();
    //
    //   expect(find.byType(SendAmountScreen), findsOneWidget);
    //   final amountBloc = get<SendAmountBloc>();
    //   expect(amountBloc.asset, asset);
    //   expect(amountBloc.receivingAddress, "Address");
    // });
  });
}
