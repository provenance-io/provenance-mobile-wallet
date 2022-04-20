import 'package:decimal/decimal.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_asset_list.dart';

import '../send_flow_test_constants.dart';

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
        0,
        "nHash",
        Decimal.fromInt(123),
        52,
      );
      await _build(tester, asset);

      final numberFormat = intl.NumberFormat.simpleCurrency();
      final textFind = find.byType(PwText);
      expect(textFind, findsNWidgets(3));
      expect(
        find.descendant(of: textFind, matching: find.text("Hash")),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: textFind,
          matching: find.text(
            numberFormat.format(52 * 123),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: textFind, matching: find.text("123")),
        findsOneWidget,
      );
      expect(find.byType(SvgPicture), findsOneWidget);
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
              assets,
              selectedAsset,
              onAssetSelected,
            ),
          ),
        ),
      );
    }

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
        [hashAsset, dollarAsset],
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
        [hashAsset, dollarAsset],
        null,
      );
      expect(find.text("Loading assets"), findsNothing);

      final dropDownFind =
          find.byWidgetPredicate((widget) => widget is PwDropDown<SendAsset>);
      final dropDown = tester.widget<PwDropDown<SendAsset>>(dropDownFind);
      expect(dropDown.initialValue, hashAsset);
    });

    testWidgets("non-empty assets, asset selected", (tester) async {
      await _build(
        tester,
        [hashAsset, dollarAsset],
        dollarAsset,
      );
      expect(find.text("Loading assets"), findsNothing);

      final dropDownFind =
          find.byWidgetPredicate((widget) => widget is PwDropDown<SendAsset>);
      final dropDown = tester.widget<PwDropDown<SendAsset>>(dropDownFind);
      expect(dropDown.initialValue, dollarAsset);
    });

    testWidgets("Value Changed", (tester) async {
      await _build(
        tester,
        [hashAsset, dollarAsset],
        dollarAsset,
      );
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
