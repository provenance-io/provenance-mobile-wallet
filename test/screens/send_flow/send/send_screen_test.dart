import 'dart:async';

import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/screens/send_flow/send/recent_send_list.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_asset_list.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_bloc.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_screen.dart';
import 'package:provenance_wallet/util/strings.dart';

import '../send_flow_test_constants.dart';
import 'send_screen_test.mocks.dart';

final get = GetIt.instance;

@GenerateMocks([SendBloc])
main() {
  StreamController<SendBlocState>? _streamController;

  MockSendBloc? mockBloc;

  setUp(() {
    _streamController = StreamController<SendBlocState>();

    mockBloc = MockSendBloc();
    when(mockBloc!.stream).thenAnswer((_) => _streamController!.stream);
    when(mockBloc!.onDispose()).thenAnswer((_) => Future.value());

    get.registerSingleton<SendBloc>(mockBloc!);
  });

  tearDown(() {
    get.unregister<SendBloc>();
    _streamController!.close();
  });

  group("SendScreen", () {
    Future<void> _build(WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SendScreen(),
          ),
        ),
      );
    }

    testWidgets("Contents", (tester) async {
      await _build(tester);

      expect(find.byType(SendPage), findsOneWidget);
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text("Send")),
        findsOneWidget,
      );
    });
  });

  group("SendPage", () {
    final recentAddress1 =
        RecentAddress("Address1", DateTime.fromMillisecondsSinceEpoch(0));
    final recentAddress2 =
        RecentAddress("Address2", DateTime.fromMillisecondsSinceEpoch(100));

    Future<void> _build(WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SendPage(),
          ),
        ),
      );
    }

    testWidgets("Contents", (tester) async {
      await _build(tester);

      expect(find.text(Strings.sendPageSelectAsset), findsOneWidget);
      expect(find.text(Strings.sendPageScanQrCode), findsOneWidget);
      expect(find.text(Strings.sendPageSendToAddressLabel), findsOneWidget);
      expect(find.byType(SendAssetList), findsOneWidget);
      expect(find.byType(RecentSendList), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(PwButton),
          matching: find.text("Next"),
        ),
        findsOneWidget,
      );
    });

    group("Asset List", () {
      testWidgets("Bloc State - assets", (tester) async {
        await _build(tester);

        var sendListFind = find.byType(SendAssetList);
        var sendList = tester.widget<SendAssetList>(sendListFind);
        expect(sendList.assets, <SendAsset>[]);

        _streamController!
            .add(SendBlocState([hashAsset, dollarAsset], <RecentAddress>[]));
        await tester.pumpAndSettle();

        sendListFind = find.byType(SendAssetList);
        sendList = tester.widget<SendAssetList>(sendListFind);
        expect(sendList.assets, [hashAsset, dollarAsset]);
      });

      testWidgets("asset selected", (tester) async {
        _streamController!
            .add(SendBlocState([hashAsset, dollarAsset], <RecentAddress>[]));

        await _build(tester);
        await tester.pumpAndSettle(); // wait for stream builder to settles

        var sendListFind = find.byType(SendAssetList);
        var sendList = tester.widget<SendAssetList>(sendListFind);
        expect(sendList.selectedAsset, null);

        await tester.tap(sendListFind);
        await tester.pumpAndSettle(); // wait for drop down menu to appear

        final dropDownCellFind = find.byType(SendAssetCell);
        await tester.tap(dropDownCellFind.last);
        await tester.pumpAndSettle(); // wait for drop down menu to appear

        sendListFind = find.byType(SendAssetList);
        sendList = tester.widget<SendAssetList>(sendListFind);
        expect(sendList.selectedAsset, dollarAsset);
      });
    });

    group("Qr Code", () {
      testWidgets("Launch QR scanner", (tester) async {
        await _build(tester);
        const returnedString = "ReturnedString";
        when(mockBloc!.scanAddress())
            .thenAnswer((_) => Future.value(returnedString));

        final iconFind = find.byType(PwIcon);
        await tester.tap(iconFind);

        verify(mockBloc!.scanAddress());

        final textFind = find.byType(TextField);
        final textField = tester.widget<TextField>(textFind);
        expect(textField.controller!.text, returnedString);
      });

      testWidgets("QR scanner - return Error", (tester) async {
        await _build(tester);
        final error = Exception("Test");
        when(mockBloc!.scanAddress()).thenAnswer((_) => Future.error(error));

        final iconFind = find.byType(PwIcon);
        await tester.tap(iconFind);
        await tester.pumpAndSettle(Duration(seconds: 3));

        final errorFind = find.byType(ErrorDialog);
        expect(errorFind, findsOneWidget);
        expect(
          find.descendant(
            of: errorFind,
            matching: find.text("Exception: Test"),
          ),
          findsOneWidget,
        );
      });
    });

    group("recent send list", () {
      testWidgets("Bloc State", (tester) async {
        await _build(tester);

        var sendListFind = find.byType(RecentSendList);
        var sendList = tester.widget<RecentSendList>(sendListFind);

        expect(sendList.recentAddresses, <RecentAddress>[]);

        _streamController!.add(
          SendBlocState(<SendAsset>[], [recentAddress1, recentAddress2]),
        );
        await tester.pumpAndSettle();

        sendListFind = find.byType(RecentSendList);
        sendList = tester.widget<RecentSendList>(sendListFind);
        expect(sendList.recentAddresses, [recentAddress1, recentAddress2]);
      });

      testWidgets("recentSend clicked", (tester) async {
        _streamController!.add(
          SendBlocState(<SendAsset>[], [recentAddress1, recentAddress2]),
        );
        await _build(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text(recentAddress1.address));

        final textFind = find.byType(TextField);
        final addressFind = find.descendant(
            of: textFind, matching: find.text(recentAddress1.address));
        expect(addressFind, findsOneWidget);
      });

      testWidgets("View All clicked", (tester) async {
        _streamController!.add(
          SendBlocState(<SendAsset>[], [recentAddress1, recentAddress2]),
        );
        await _build(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text("View All"));

        verify(mockBloc!.showAllRecentSends());
      });
    });

    group("Next", () {
      testWidgets("Clicked with no values entered", (tester) async {
        when(mockBloc!.next(any, any)).thenAnswer((_) => Future.value());
        await _build(tester);

        await tester.tap(find.text("Next"));
        verify(mockBloc!.next("", null));
      });

      testWidgets("Error", (tester) async {
        final ex = Exception("Test");
        when(mockBloc!.next(any, any)).thenAnswer((_) => Future.error(ex));

        await _build(tester);

        await tester.tap(find.text("Next"));
        await tester.pumpAndSettle();

        final dialogFind = find.byType(ErrorDialog);
        expect(dialogFind, findsOneWidget);
        expect(
          find.descendant(
            of: dialogFind,
            matching: find.text("Exception: Test"),
          ),
          findsOneWidget,
        );
      });

      testWidgets("Values", (tester) async {
        _streamController!.add(SendBlocState(
            [hashAsset, dollarAsset], [recentAddress1, recentAddress2]));
        when(mockBloc!.next(any, any)).thenAnswer((_) => Future.value());

        await _build(tester);
        await tester.pumpAndSettle();

        final addressTextFind = find.byType(TextField);
        await tester.enterText(addressTextFind, "Addr");

        await tester.tap(find.byType(SendAssetList));
        await tester.pumpAndSettle();
        await tester.tap(find.text(dollarAsset.displayDenom).last);
        await tester.pumpAndSettle();

        await tester.tap(find.text("Next"));

        verify(mockBloc!.next("Addr", dollarAsset));
      });
    });
  });
}
