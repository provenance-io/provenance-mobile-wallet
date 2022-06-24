import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';

final item = ActionListItem(label: "Main Label", subLabel: "Sub Label");
final item2 = ActionListItem(label: "Main Label2", subLabel: "Sub Label2");
final item3 = ActionListItem(label: "Main Label3", subLabel: "Sub Label3");

final basicGroup = ActionListGroup(
    label: "Test Label",
    subLabel: "SubList",
    isBasicAccount: true,
    isSelected: false,
    items: [item]);

final multiSigGroup = ActionListGroup(
    label: "Test Label - multiSig",
    subLabel: "SubList",
    isBasicAccount: false,
    isSelected: false,
    items: []);

final isSelectedGroup = ActionListGroup(
    label: "Test Label - isSelected",
    subLabel: "SubList",
    isBasicAccount: false,
    isSelected: true,
    items: [item2, item3]);

main() {
  group("ActionItemGroupStatus", () {
    Matcher _StatusMatcher(Color color, String label) {
      return predicate((arg) {
        final statusWidget = arg as ActionItemGroupStatus;
        expect(statusWidget.color, color);
        expect(statusWidget.label, label);
        return true;
      });
    }

    Future<void> _build(WidgetTester tester, ActionListGroup group) async {
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: ActionItemGroupStatus(
            group: group,
          ),
        ),
      ));
    }

    testWidgets("basic account settings", (tester) async {
      await _build(tester, basicGroup);
      final status = tester
          .widget<ActionItemGroupStatus>(find.byType(ActionItemGroupStatus));

      expect(
          status,
          _StatusMatcher(ActionItemGroupStatus.notSelectedColor,
              ActionItemGroupStatus.basicLabel));
    });

    testWidgets("multiSig account settings", (tester) async {
      await _build(tester, multiSigGroup);
      final status = tester
          .widget<ActionItemGroupStatus>(find.byType(ActionItemGroupStatus));

      expect(
          status,
          _StatusMatcher(ActionItemGroupStatus.notSelectedColor,
              ActionItemGroupStatus.multiSigLabel));
    });

    testWidgets("isSelected account settings", (tester) async {
      await _build(tester, isSelectedGroup);
      final status = tester
          .widget<ActionItemGroupStatus>(find.byType(ActionItemGroupStatus));

      expect(
          status,
          _StatusMatcher(ActionItemGroupStatus.selectedColor,
              ActionItemGroupStatus.selectedLabel));
    });
  });

  group("ActionItemCell", () {
    Future<void> _build(WidgetTester tester, ActionListItem item) async {
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: ActionItemCell(
            item: item,
          ),
        ),
      ));
    }

    testWidgets("Verify contents", (tester) async {
      await _build(tester, item);

      expect(find.text(item.label), findsOneWidget);
      expect(find.text(item.subLabel), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_right), findsOneWidget);
    });
  });

  group("ActionGroupHeaderCell", () {
    Future<void> _build(WidgetTester tester, ActionListGroup group) async {
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: ActionGroupHeaderCell(
            group: group,
          ),
        ),
      ));
    }

    testWidgets("Single action", (tester) async {
      await _build(tester, basicGroup);

      expect(find.text(basicGroup.label), findsOneWidget);
      expect(find.text("${basicGroup.subLabel} • 1 Action"), findsOneWidget);
      expect(find.byType(ActionItemGroupStatus), findsOneWidget);
    });

    testWidgets("zero action", (tester) async {
      await _build(tester, multiSigGroup);

      expect(find.text(multiSigGroup.label), findsOneWidget);
      expect(
          find.text("${multiSigGroup.subLabel} • 0 Actions"), findsOneWidget);
      expect(find.byType(ActionItemGroupStatus), findsOneWidget);
    });

    testWidgets("multiple action", (tester) async {
      await _build(tester, isSelectedGroup);

      expect(find.text(isSelectedGroup.label), findsOneWidget);
      expect(
          find.text("${isSelectedGroup.subLabel} • 2 Actions"), findsOneWidget);
      expect(find.byType(ActionItemGroupStatus), findsOneWidget);
    });
  });

  group("ActionListCell", () {
    Future<void> _build(WidgetTester tester, ActionListGroup group) async {
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: ActionListCell(
            group: group,
          ),
        ),
      ));
    }

    testWidgets("Contents", (tester) async {
      await _build(tester, isSelectedGroup);

      final listFind = find.byType(ActionItemCell);
      final headerFind = find.byType(ActionGroupHeaderCell);

      expect(listFind, findsNWidgets(2));
      expect(headerFind, findsOneWidget);

      expect(tester.widget<ActionGroupHeaderCell>(headerFind).group,
          isSelectedGroup);
      expect(tester.widget<ActionItemCell>(listFind.first).item,
          isSelectedGroup.items[0]);
      expect(tester.widget<ActionItemCell>(listFind.last).item,
          isSelectedGroup.items[1]);
    });
  });

  group("ActionList", () {
    Future<void> _build(
        WidgetTester tester, List<ActionListGroup> groups) async {
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: ActionList(
            groups: groups,
          ),
        ),
      ));
    }

    testWidgets("Contents", (tester) async {
      await _build(tester, [basicGroup, multiSigGroup, isSelectedGroup]);

      final cellFind = find.byType(ActionListCell);
      expect(cellFind, findsNWidgets(3));

      expect(tester.widget<ActionListCell>(cellFind.at(0)).group, basicGroup);
      expect(
          tester.widget<ActionListCell>(cellFind.at(1)).group, multiSigGroup);
      expect(
          tester.widget<ActionListCell>(cellFind.at(2)).group, isSelectedGroup);
    });
  });
}
