import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_asset_list.dart';

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
      final asset = SendAsset(
        "Hash",
        "123",
        "52",
        "http://test.com",
      );
      await _build(tester, asset);

      final textFind = find.byType(PwText);
      expect(textFind, findsNWidgets(3));
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
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group("SendAssetList", () {
    SendAsset? assetSelected;

    void OnAssetSelected(SendAsset asset) => assetSelected = asset;

    Future<void> _build(
      WidgetTester tester,
      List<SendAsset> assets,
      SendAsset? selectedAsset,
    ) {
      return tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SendAssetList(
              assets,
              selectedAsset,
              OnAssetSelected,
            ),
          ),
        ),
      );
    }

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
      expect(find.text("Loading assets"), findsOneWidget);
      expect(find.byType(PwDropDown), findsNothing);
    });

    testWidgets("Contents non-empty list", (tester) async {
      await _build(
        tester,
        [asset1, asset2],
        null,
      );
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

    testWidgets("non-empty assets, nothing selected", (tester) async {
      await _build(
        tester,
        [asset1, asset2],
        null,
      );
      expect(find.text("Loading assets"), findsNothing);

      final dropDownFind =
          find.byWidgetPredicate((widget) => widget is PwDropDown<SendAsset>);
      final dropDown = tester.widget<PwDropDown<SendAsset>>(dropDownFind);
      expect(dropDown.initialValue, asset1);
    });

    testWidgets("non-empty assets, asset selected", (tester) async {
      await _build(
        tester,
        [asset1, asset2],
        asset2,
      );
      expect(find.text("Loading assets"), findsNothing);

      final dropDownFind =
          find.byWidgetPredicate((widget) => widget is PwDropDown<SendAsset>);
      final dropDown = tester.widget<PwDropDown<SendAsset>>(dropDownFind);
      expect(dropDown.initialValue, asset2);
    });

    testWidgets("Value Changed", (tester) async {
      await _build(
        tester,
        [asset1, asset2],
        asset2,
      );
      expect(find.text("Loading assets"), findsNothing);

      final dropDownFind =
          find.byWidgetPredicate((widget) => widget is PwDropDown<SendAsset>);
      await tester.tap(dropDownFind);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SendAssetCell).last);
      expect(assetSelected, asset2);
    });
  });
}
