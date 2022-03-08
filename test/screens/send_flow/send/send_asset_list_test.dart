<<<<<<< HEAD
import 'package:decimal/decimal.dart';
=======
>>>>>>> develop
import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_asset_list.dart';
<<<<<<< HEAD

import '../send_flow_test_constants.dart';
=======
>>>>>>> develop

main() {
  group("SendAssetCell", () {
    Future<void> _build(WidgetTester tester, SendAsset asset) {
      return tester.pumpWidget(
        Material(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SendAssetCell(asset),
          ),
        ),
      );
    }

    testWidgets("Contents", (tester) async {
<<<<<<< HEAD
      final asset = SendAsset("Hash", 0, "nHash", Decimal.fromInt(123), "52", "http://test.com",);
=======
      final asset = SendAsset(
        "Hash",
        "123",
        "52",
        "http://test.com",
      );
>>>>>>> develop
      await _build(tester, asset);

      final textFind = find.byType(PwText);
      expect(textFind, findsNWidgets(3));
<<<<<<< HEAD
      expect(find.descendant(of: textFind, matching: find.text("Hash")), findsOneWidget);
      expect(find.descendant(of: textFind, matching: find.text("52")), findsOneWidget);
      expect(find.descendant(of: textFind, matching: find.text("123")), findsOneWidget);
=======
      expect(
        find.descendant(of: textFind, matching: find.text("Hash")),
        findsOneWidget,
      );
      expect(
        find.descendant(of: textFind, matching: find.text("52")),
        findsOneWidget,
      );
      expect(
        find.descendant(of: textFind, matching: find.text("123 Hash")),
        findsOneWidget,
      );
>>>>>>> develop
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group("SendAssetList", () {
    SendAsset? assetSelected;

    void onAssetSelected(SendAsset asset) => assetSelected = asset;

    Future<void> _build(
      WidgetTester tester,
      List<SendAsset> assets,
      SendAsset? selectedAsset,
    ) {
      return tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SendAssetList(
<<<<<<< HEAD
                assets,
                selectedAsset,
                OnAssetSelected,
=======
              assets,
              selectedAsset,
              onAssetSelected,
>>>>>>> develop
            ),
          ),
        ),
      );
    }

<<<<<<< HEAD
    testWidgets("Contents empty assets", (tester)  async {
      await _build(tester, <SendAsset>[], null,);
=======
    final asset1 = SendAsset(
      "Hash",
      "1",
      "1.30",
      "http://test.com",
    );
    final asset2 = SendAsset(
      "USD",
      "1",
      "1",
      "http://test1.com",
    );

    testWidgets("Contents empty assets", (tester) async {
      await _build(
        tester,
        <SendAsset>[],
        null,
      );
>>>>>>> develop
      expect(find.text("Loading assets"), findsOneWidget);
      expect(find.byType(PwDropDown), findsNothing);
    });

<<<<<<< HEAD
    testWidgets("Contents non-empty list", (tester)  async {
      await _build(tester, [ hashAsset, dollarAsset ], null,);
=======
    testWidgets("Contents non-empty list", (tester) async {
      await _build(
        tester,
        [asset1, asset2],
        null,
      );
>>>>>>> develop
      expect(find.text("Loading assets"), findsNothing);

      final dropDownFind =
          find.byWidgetPredicate((widget) => widget is PwDropDown<SendAsset>);
      expect(dropDownFind, findsOneWidget);

      final cellFind = find.descendant(
        of: dropDownFind,
        matching: find.byType(SendAssetCell),
      );
      expect(cellFind, findsNWidgets(2));
    });

<<<<<<< HEAD
    testWidgets("non-empty assets, nothing selected", (tester)  async {
      await _build(tester, [ hashAsset, dollarAsset ], null,);
=======
    testWidgets("non-empty assets, nothing selected", (tester) async {
      await _build(
        tester,
        [asset1, asset2],
        null,
      );
>>>>>>> develop
      expect(find.text("Loading assets"), findsNothing);

      final dropDownFind =
          find.byWidgetPredicate((widget) => widget is PwDropDown<SendAsset>);
      final dropDown = tester.widget<PwDropDown<SendAsset>>(dropDownFind);
      expect(dropDown.initialValue, hashAsset);
    });

<<<<<<< HEAD
    testWidgets("non-empty assets, asset selected", (tester)  async {
      await _build(tester, [ hashAsset, dollarAsset ], dollarAsset,);
=======
    testWidgets("non-empty assets, asset selected", (tester) async {
      await _build(
        tester,
        [asset1, asset2],
        asset2,
      );
>>>>>>> develop
      expect(find.text("Loading assets"), findsNothing);

      final dropDownFind =
          find.byWidgetPredicate((widget) => widget is PwDropDown<SendAsset>);
      final dropDown = tester.widget<PwDropDown<SendAsset>>(dropDownFind);
      expect(dropDown.initialValue, dollarAsset);
    });

<<<<<<< HEAD
    testWidgets("Value Changed", (tester)  async {
      await _build(tester, [ hashAsset, dollarAsset ], dollarAsset,);
=======
    testWidgets("Value Changed", (tester) async {
      await _build(
        tester,
        [asset1, asset2],
        asset2,
      );
>>>>>>> develop
      expect(find.text("Loading assets"), findsNothing);

      final dropDownFind =
          find.byWidgetPredicate((widget) => widget is PwDropDown<SendAsset>);
      await tester.tap(dropDownFind);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SendAssetCell).last);
      expect(assetSelected, dollarAsset);
    });
  });
}
