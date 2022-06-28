import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/notification_bell.dart';

const _goldenRoot = "../../goldens/common/widgets/notification_bell";

main() {
  Future<void> _build(WidgetTester tester, int notificationCount,
      {Color? activeColor,
      Color? inactiveColor,
      int? placeCount,
      Duration? animationDuration}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 64,
          height: 64,
          child: RepaintBoundary(
            child: NotificationBell(
              notificationCount: notificationCount,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              placeCount: placeCount,
              animationDuration: animationDuration,
            ),
          ),
        ),
      ),
    ));
  }

  testWidgets("Verify defaults", (tester) async {
    await _build(tester, 0);
    final bellFind = find.byType(NotificationBell);
    final bell = tester.widget<NotificationBell>(bellFind);

    expect(bell.placeCount, 3);
    expect(bell.animationDuration, const Duration(milliseconds: 75));
    expect(bell.activeColor, Colors.white);
    expect(bell.inactiveColor, Colors.grey);
  });

  testWidgets("verify assertions work", (tester) async {
    expect(() => _build(tester, -1), throwsAssertionError);
    expect(() => _build(tester, 1, placeCount: 0), throwsAssertionError);
  });

  group("notification count label", () {
    testWidgets('no notification should not show a badge', (tester) async {
      await _build(tester, 0);
      final badgeFind = find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration != null);
      expect(badgeFind, findsNothing);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('badge appears when a notifiction exists', (tester) async {
      await _build(tester, 1);
      final badgeFind = find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration != null);
      expect(badgeFind, findsOneWidget);
      expect(find.text("1"), findsOneWidget);
    });

    testWidgets('badge count exceeds placeCount', (tester) async {
      await _build(tester, 101, placeCount: 2);
      final badgeFind = find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration != null);
      expect(badgeFind, findsOneWidget);
      expect(find.text("100+"), findsOneWidget);
    });
  });

  group("colors", () {
    testWidgets('default active and interactive colors', (tester) async {
      await _build(tester, 0);

      final bellFind = find.byType(NotificationBell);
      await expectLater(bellFind,
          matchesGoldenFile("$_goldenRoot/inactive-defaultColor.png"));

      await _build(tester, 1);
      await expectLater(
          bellFind, matchesGoldenFile("$_goldenRoot/active-defaultColor.png"));
    });

    testWidgets('custom active and interactive colors', (tester) async {
      await _build(tester, 0,
          activeColor: Colors.blue, inactiveColor: Colors.pink);

      final bellFind = find.byType(NotificationBell);
      await expectLater(
          bellFind, matchesGoldenFile("$_goldenRoot/inactive-customColor.png"));

      await _build(tester, 1,
          activeColor: Colors.blue, inactiveColor: Colors.pink);
      await expectLater(
          bellFind, matchesGoldenFile("$_goldenRoot/active-customColor.png"));
    });
  });

  group("animation", () {
    testWidgets("animate on value change", (tester) async {
      await _build(tester, 0);

      await _build(tester, 1);
      final bellFind = find.byType(NotificationBell);
      final bell = tester.widget<NotificationBell>(bellFind);

      // note: The duration is for running the animation forward, we then need to run it backwards
      // we repeat this 3 times.
      final oneLoopDuration = 2 * bell.animationDuration.inMilliseconds;

      for (int milliseconds = 0;
          milliseconds <= oneLoopDuration;
          milliseconds += (oneLoopDuration ~/ 6)) {
        await tester.pump(Duration(
            milliseconds: 25)); // move the animation forward 25 milliseconds
        await expectLater(
            bellFind,
            matchesGoldenFile(
                "$_goldenRoot/count-change-animation/$milliseconds-milliseconds.png"));
      }
    });
  });
}
