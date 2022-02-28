import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_divider.dart';
import 'package:provenance_wallet/screens/send_flow/send/recent_send_list.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_bloc.dart';

main() {
  group("RecentSendCell", () {
    Future<void> _build(WidgetTester tester, RecentAddress? recentAddress) {
      return tester.pumpWidget(
        Material(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: RecentSendCell(recentAddress),
          ),
        ),
      );
    }

    testWidgets("Null Address", (tester) async {
      await _build(tester, null);

      final textFind = find.byType(PwText);

      expect(textFind, findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      expect(
        find.descendant(of: textFind, matching: find.text("View All")),
        findsOneWidget,
      );
    });

    testWidgets("Not Null Address", (tester) async {
      final lastSend = DateTime.fromMicrosecondsSinceEpoch(0);
      final recentAddress = RecentAddress("Address", lastSend);
      await _build(tester, recentAddress);

      final textFind = find.byType(PwText);

      expect(textFind, findsNWidgets(2));
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      expect(find.text("View All"), findsNothing);
      expect(
        find.descendant(of: textFind, matching: find.text("Address")),
        findsOneWidget,
      );

      final lastSendFinder = find.byKey(RecentSendCell.keyLastSendText);
      expect(lastSendFinder, findsOneWidget);

      final lastSendWidget = lastSendFinder.evaluate().first.widget as Text;
      expect(lastSendWidget.data, dateFormatter.format(lastSend));
    });
  });

  group("RecentSendList", () {
    int viewAllClicked = 0;
    RecentAddress? recentlyClickedAddress;

    void OnViewAllClicked() => viewAllClicked += 1;

    void OnAddressClicked(RecentAddress address) =>
        recentlyClickedAddress = address;

    final send1 =
        RecentAddress("Address1", DateTime.fromMicrosecondsSinceEpoch(0));
    final send2 =
        RecentAddress("Address2", DateTime.fromMicrosecondsSinceEpoch(0));

    Future<void> _build(
      WidgetTester tester,
      List<RecentAddress> recentAddresses,
    ) {
      return tester.pumpWidget(
        MaterialApp(
          home: RecentSendList(
            recentAddresses,
            OnAddressClicked,
            OnViewAllClicked,
          ),
        ),
      );
    }

    setUp(() {
      viewAllClicked = 0;
      recentlyClickedAddress = null;
    });

    testWidgets("Empty List", (tester) async {
      await _build(tester, <RecentAddress>[]);
      final cellFind = find.byType(RecentSendCell);
      expect(cellFind, findsNothing);
      expect(find.text("No recent sends"), findsOneWidget);
    });

    testWidgets("Non-Empty List", (tester) async {
      await _build(tester, [send1, send2]);
      final cellFind = find.byType(RecentSendCell);
      expect(find.text("No recent sends"), findsNothing);
      expect(find.byType(PwDivider), findsNWidgets(2));

      expect(cellFind, findsNWidgets(3));
      expect(
        tester.widget<RecentSendCell>(cellFind.at(0)).recentAddress,
        send1,
      );
      expect(
        tester.widget<RecentSendCell>(cellFind.at(1)).recentAddress,
        send2,
      );
      expect(tester.widget<RecentSendCell>(cellFind.at(2)).recentAddress, null);
    });

    testWidgets("send Clicked", (tester) async {
      await _build(tester, [send1, send2]);

      await tester.tap(find.text(send1.address));
      expect(recentlyClickedAddress!, send1);

      await tester.tap(find.text(send2.address));
      expect(recentlyClickedAddress!, send2);

      expect(viewAllClicked, 0);
    });

    testWidgets("View All Clicked", (tester) async {
      await _build(tester, [send1, send2]);
      final cellFind = find.byType(RecentSendCell);

      await tester.tap(cellFind.at(2));
      expect(recentlyClickedAddress, null);
      expect(viewAllClicked, 1);
    });
  });
}
