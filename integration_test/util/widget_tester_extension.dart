// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/util/integration_test_data.dart';

extension WidgetTesterExtension on WidgetTester {
  Future<IntegrationTestData> loadTestData() async {
    const json = String.fromEnvironment('TEST_DATA_JSON');

    expect(
      json.isNotEmpty,
      isTrue,
      reason: 'No test data.',
    );

    return IntegrationTestData.fromJson(jsonDecode(json));
  }

  void expectKey(Key key) {
    try {
      expect(find.byKey(key), findsOneWidget);
    } on Exception catch (_) {
      print('===== Start widget dump =====');

      final app = WidgetsBinding.instance?.renderViewElement?.toStringDeep();
      print(app);

      print('===== End widget dump =======');

      rethrow;
    }
  }

  Future<void> unfocusAndSettle() async {
    FocusManager.instance.primaryFocus?.unfocus();

    await pumpAndSettle();
  }

  T widgetWithKey<T extends Widget>(Key key) {
    expectKey(key);

    return firstWidget<T>(find.byKey(key));
  }

  Future<void> enterTextAndSettle(Key key, String text) async {
    expectKey(key);

    await enterText(find.byKey(key), text);

    await pumpAndSettle();
  }

  Future<void> tapKeyAndSettle(Key key, {int times = 1}) async {
    expectKey(key);

    for (var i = 0; i < times; i++) {
      await tap(find.byKey(key));
    }

    await pumpAndSettle();
  }

  Future<void> scrollUntilVisibleAndSettle({
    required Key key,
    required Key scrollable,
  }) async {
    expectKey(scrollable);

    await dragUntilVisible(
      find.byKey(key),
      find.byKey(scrollable),
      Offset(0, -200),
    );

    await pumpAndSettle();

    expectKey(key);
  }
}
