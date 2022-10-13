import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
import 'package:provenance_wallet/util/localized_string.dart';
import 'package:provenance_wallet/util/strings.dart';

final item = ActionListItem(
  label: LocalizedString((_) => "Main Label"),
  subLabel: LocalizedString((_) => "Sub Label"),
);
final item2 = ActionListItem(
  label: LocalizedString((_) => "Main Label2"),
  subLabel: LocalizedString((_) => "Sub Label2"),
);
final item3 = ActionListItem(
  label: LocalizedString((_) => "Main Label3"),
  subLabel: LocalizedString((_) => "Sub Label3"),
);

const actionListSelected = "Selected";
const actionListBasicAccount = "Basic";
const actionListMultiSigAccount = "Multi-Sig";

final basicGroup = ActionListGroup(
    accountId: 'one',
    label: "Test Label",
    subLabel: "SubList",
    isBasicAccount: true,
    isSelected: false,
    items: [item]);

final multiSigGroup = ActionListGroup(
    accountId: 'two',
    label: "Test Label - multiSig",
    subLabel: "SubList",
    isBasicAccount: false,
    isSelected: false,
    items: []);

final isSelectedGroup = ActionListGroup(
    accountId: 'three',
    label: "Test Label - isSelected",
    subLabel: "SubList",
    isBasicAccount: false,
    isSelected: true,
    items: [item2, item3]);

main() {
  group("ActionItemGroupStatus", () {
    Matcher createStatusMatcher(
        WidgetTester widgetTester, Color color, String label) {
      return predicate((arg) {
        final statusWidget = arg as ActionItemGroupStatus;
        expect(statusWidget.label, label);

        final boxDecorationFind = find.byType(Container);
        final container = widgetTester.widget<Container>(boxDecorationFind);

        final boxDecoration = container.decoration as BoxDecoration;
        expect(boxDecoration.color, color);

        return true;
      });
    }

    Future<void> _build(WidgetTester tester, ActionListGroup group) async {
      await tester.pumpWidget(MaterialApp(
        theme: ProvenanceThemeData.themeData,
        home: Material(
          child: ActionItemGroupStatus(
            selectedLabel: actionListSelected,
            basicLabel: actionListBasicAccount,
            multiSigLabel: actionListMultiSigAccount,
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
          createStatusMatcher(
            tester,
            (ProvenanceThemeData.themeData.colorScheme as ProvenanceColorScheme)
                .actionNotListSelectedColor,
            actionListBasicAccount,
          ));
    });

    testWidgets("multiSig account settings", (tester) async {
      await _build(tester, multiSigGroup);
      final status = tester
          .widget<ActionItemGroupStatus>(find.byType(ActionItemGroupStatus));

      expect(
          status,
          createStatusMatcher(
            tester,
            (ProvenanceThemeData.themeData.colorScheme as ProvenanceColorScheme)
                .actionNotListSelectedColor,
            actionListMultiSigAccount,
          ));
    });

    testWidgets("isSelected account settings", (tester) async {
      await _build(tester, isSelectedGroup);
      final status = tester
          .widget<ActionItemGroupStatus>(find.byType(ActionItemGroupStatus));

      expect(
          status,
          createStatusMatcher(
            tester,
            (ProvenanceThemeData.themeData.colorScheme as ProvenanceColorScheme)
                .actionListSelectedColor,
            actionListSelected,
          ));
    });
  });

  group("ActionItemCell", () {
    Future<void> _build(WidgetTester tester, ActionListItem item) async {
      await tester.pumpWidget(MaterialApp(
        theme: ProvenanceThemeData.themeData,
        home: Material(
          child: ActionItemCell(
            item: item,
          ),
        ),
      ));
    }

    testWidgets("Verify contents", (tester) async {
      await _build(tester, item);
      final context = tester.allElements.last;

      expect(find.text(item.label.get(context)), findsOneWidget);
      expect(find.text(item.subLabel.get(context)), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_right), findsOneWidget);
    });
  });

  group("ActionGroupHeaderCell", () {
    Future<void> _build(WidgetTester tester, ActionListGroup group) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ProvenanceThemeData.themeData,
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
      expect(
          find.text("${basicGroup.subLabel} ${Strings.dotSeparator} 1 Action"),
          findsOneWidget);
      expect(find.byType(ActionItemGroupStatus), findsOneWidget);
    });

    testWidgets("zero action", (tester) async {
      await _build(tester, multiSigGroup);

      expect(find.text(multiSigGroup.label), findsOneWidget);
      expect(
          find.text(
              "${multiSigGroup.subLabel} ${Strings.dotSeparator} 0 Actions"),
          findsOneWidget);
      expect(find.byType(ActionItemGroupStatus), findsOneWidget);
    });

    testWidgets("multiple action", (tester) async {
      await _build(tester, isSelectedGroup);

      expect(find.text(isSelectedGroup.label), findsOneWidget);
      expect(
          find.text(
              "${isSelectedGroup.subLabel} ${Strings.dotSeparator} 2 Actions"),
          findsOneWidget);
      expect(find.byType(ActionItemGroupStatus), findsOneWidget);
    });
  });

  group("ActionListCell", () {
    Future<void> _build(WidgetTester tester, ActionListGroup group) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ProvenanceThemeData.themeData,
        home: Material(
          child: ActionListCell(
            group: group,
            onItemCliecked: (group, item) {},
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ProvenanceThemeData.themeData,
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
