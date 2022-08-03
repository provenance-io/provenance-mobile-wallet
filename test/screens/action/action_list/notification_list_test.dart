import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
import 'package:provenance_wallet/screens/action/action_list/notification_list.dart';

extension _WidgetTesterHelper on WidgetTester {
  Future<void> tapAndSettle(Finder finder) {
    return tap(finder).then((_) => pumpAndSettle());
  }
}

main() {
  group("NotificationItemCell", () {
    const duration = Duration(milliseconds: 200);
    AnimationController? animationController;

    final item = NotificationItem(
        created: DateTime.fromMillisecondsSinceEpoch(1000), label: "TestLabel");

    Future<void> _build(WidgetTester tester, NotificationItem item,
        ValueNotifier<bool> selected, Animation<double> animation) async {
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: NotificationItemCell(
            item: item,
            isSelected: selected,
            animation: animation,
          ),
        ),
      ));
    }

    tearDown(() {
      animationController?.dispose();
    });

    testWidgets("labels", (tester) async {
      animationController =
          AnimationController(vsync: tester, duration: duration);
      final selected = ValueNotifier(false);
      await _build(tester, item, selected, animationController!);

      expect(find.text("TestLabel"), findsOneWidget);
      expect(
          find.text(NotificationItemCell.notificationListFormatter
              .format(item.created)),
          findsOneWidget);
    });

    testWidgets("show/hide checkbox animation", (tester) async {
      animationController =
          AnimationController(vsync: tester, duration: duration);

      final selected = ValueNotifier(false);
      await _build(tester, item, selected, animationController!);

      final checkBoxFind = find.byType(Checkbox);
      final textFind = find.byType(Expanded);

      expect(tester.getRect(checkBoxFind).right,
          0); // checkbox if off the left side
      expect(tester.getRect(textFind).left,
          0); // text box should be pined to left side

      animationController!.forward();
      await tester.pumpAndSettle();
      expect(tester.getRect(checkBoxFind).left, 0); // checkbox is visible
      expect(
          tester.getRect(textFind).left,
          tester
              .getRect(checkBoxFind)
              .right); // text box should be pined to left side
    });

    testWidgets("checkbox reflects selected notifier", (tester) async {
      animationController =
          AnimationController(vsync: tester, duration: duration);

      final selected = ValueNotifier(false);
      await _build(tester, item, selected, animationController!);

      final checkBoxFind = find.byType(Checkbox);
      expect(tester.widget<Checkbox>(checkBoxFind).value, false);

      selected.value = true;
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(checkBoxFind).value, true);
    });

    testWidgets("selected notifier updated when checkbox clicked",
        (tester) async {
      animationController =
          AnimationController(vsync: tester, duration: duration);

      final selected = ValueNotifier(false);
      await _build(tester, item, selected, animationController!);

      // can not tap if the checkbox is off screen
      animationController!.forward();
      await tester.pumpAndSettle();

      final checkBoxFind = find.byType(Checkbox);
      await tester.tap(checkBoxFind);
      await tester
          .pumpAndSettle(); // wait for checkbox internal animation to finish

      expect(selected.value, true);
      await tester.tap(checkBoxFind);
      await tester
          .pumpAndSettle(); // wait for checkbox internal animation to finish

      expect(selected.value, false);
    });
  });

  group("NotificationList", () {
    final item1 = NotificationItem(
        label: "item1", created: DateTime.fromMillisecondsSinceEpoch(1000));
    final item2 = NotificationItem(
        label: "item2", created: DateTime.fromMillisecondsSinceEpoch(3000));

    Future<void> _build(WidgetTester tester, List<NotificationItem> items,
        NotificationItemsDelegate itemsDeletedDelegate) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Material(
          child: NotificationList(
            items: items,
            onItemsDeleted: itemsDeletedDelegate,
          ),
        ),
      ));
    }

    testWidgets("items converted to list items", (tester) async {
      await _build(tester, [item1, item2], (items) {});

      final cellFind = find.byType(NotificationItemCell);
      expect(cellFind, findsNWidgets(2));

      expect(tester.widget<NotificationItemCell>(cellFind.first).item, item1);
      expect(tester.widget<NotificationItemCell>(cellFind.last).item, item2);
    });

    testWidgets("Edit button", (tester) async {
      await _build(tester, [item1, item2], (items) {});

      final editFind = find.text("Edit");
      expect(editFind, findsOneWidget);

      await tester.tapAndSettle(editFind); // allow listenables to update
      expect(editFind, findsNothing);
    });

    testWidgets("Edit shows action buttons", (tester) async {
      await _build(tester, [item1, item2], (items) {});

      final listRect = tester.getRect(find.byType(NotificationList));

      isOffScreen(Finder finder) {
        final rect = tester.getRect(finder);
        return rect.top > listRect.bottom;
      }

      // initially hidden
      expect(isOffScreen(find.text("Delete")), true);
      expect(isOffScreen(find.text("Cancel")), true);

      final editFind = find.text("Edit");

      await tester.tapAndSettle(editFind);

      expect(isOffScreen(find.text("Delete")), false);
      expect(isOffScreen(find.text("Cancel")), false);
    });

    testWidgets("Cancel hides action buttons", (tester) async {
      await _build(tester, [item1, item2], (items) {});

      final listRect = tester.getRect(find.byType(NotificationList));

      isOffScreen(Finder finder) {
        final rect = tester.getRect(finder);
        return rect.top > listRect.bottom;
      }

      final editFind = find.text("Edit");
      await tester.tapAndSettle(editFind);
      await tester.tapAndSettle(find.text("Cancel"));

      expect(isOffScreen(find.text("Delete")), true);
      expect(isOffScreen(find.text("Cancel")), true);
    });

    testWidgets("Delete button triggers confirmation", (tester) async {
      List<NotificationItem> delegateItems = [];

      await _build(tester, [item1, item2], (items) {
        delegateItems.addAll(items);
      });

      final editFind = find.text("Edit");
      await tester.tapAndSettle(editFind);

      final checkBoxes = find.byType(Checkbox);
      await tester.tapAndSettle(checkBoxes.last);

      await tester.tapAndSettle(find.text("Delete"));
      expect(delegateItems, [item2]);
    });
  });
}
