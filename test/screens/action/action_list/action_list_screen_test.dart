import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_screen.dart';
import 'package:provenance_wallet/screens/action/action_list/notification_list.dart';
import 'package:provenance_wallet/services/account_notification_service/account_notification_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provider/provider.dart';

import './action_list_screen_test.mocks.dart';

@GenerateMocks([ActionListBloc])
main() {
  group("ActionListTab", () {
    Future<void> _build(WidgetTester tester, String label, int count) async {
      await tester.pumpWidget(MaterialApp(
        theme: ProvenanceThemeData.themeData,
        home: Material(
          child: ActionListTab(
            label: label,
            count: count,
          ),
        ),
      ));
    }

    testWidgets("contents", (tester) async {
      await _build(tester, "Items", 3);
      expect(find.text("Items (3)"), findsOneWidget);
    });
  });

  group("ActionListScreen", () {
    late MockActionListBloc mockBloc;
    late StreamController<ActionListBlocState> _streamController;

    Future<void> _build(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ProvenanceThemeData.themeData,
        home: Material(
            child: Provider<ActionListBloc>(
          create: (_) => mockBloc,
          child: ActionListScreen(),
        )),
      ));
    }

    setUp(() async {
      final accountNotificationService = AccountNotificationService(
        inMemory: true,
      );
      await accountNotificationService.add(
        label: 'Test',
        created: DateTime.now(),
      );

      get.registerSingleton(accountNotificationService);

      _streamController = StreamController<ActionListBlocState>();

      mockBloc = MockActionListBloc();
      when(mockBloc.onDispose()).thenAnswer((_) => Future.value());
      when(mockBloc.stream).thenAnswer((_) => _streamController.stream);
    });

    tearDown(() async {
      _streamController.close();

      get.unregister<AccountNotificationService>();
    });

    testWidgets("empty screen when there is no state", (tester) async {
      await _build(tester);
      expect(find.byType(ActionList), findsNothing);
      expect(find.byType(NotificationList), findsNothing);
      expect(find.byType(TabBar), findsNothing);
      expect(find.byType(TabBarView), findsNothing);
    });

    testWidgets("empty screen when there is no state", (tester) async {
      await _build(tester);
      _streamController.add(ActionListBlocState(
        [
          ActionListGroup(
            accountId: 'test',
            label: "ActionLabel",
            subLabel: "ActionSubLabel",
            isSelected: true,
            isBasicAccount: true,
            items: [],
          )
        ],
      ));

      await tester.pumpAndSettle(); // let the builder complete

      expect(find.byType(ActionList), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);

      final tabFind = find.byType(ActionListTab);

      final notificationTabFind = tabFind.last;
      final actionTabFind = tabFind.first;

      expect(notificationTabFind, findsOneWidget);
      expect(actionTabFind, findsOneWidget);

      expect(tester.widget<ActionListTab>(notificationTabFind).count, 1);
      expect(tester.widget<ActionListTab>(actionTabFind).count, 1);

      await tester.tap(notificationTabFind);
      await tester.pumpAndSettle();
      expect(find.byType(NotificationList), findsOneWidget);
    });
  });
}
