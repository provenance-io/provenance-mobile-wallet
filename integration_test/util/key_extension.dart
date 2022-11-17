import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/common/widgets/pw_text.dart';

import 'widget_tester_extension.dart';

extension KeyExtension on Key {
  Future<void> tap(ft.WidgetTester tester, {int times = 1}) {
    return tester.tapKeyAndSettle(this, times: times);
  }

  Future<void> tapWhenExists(ft.WidgetTester tester) async {
    while (tester
        .widgetList(
          find.byKey(this),
        )
        .isEmpty) {
      await tester.pumpAndSettle();
    }
    return tester.tapKeyAndSettle(this);
  }

  Future<void> enterText(String text, ft.WidgetTester tester) {
    return tester.enterTextAndSettle(this, text);
  }

  void expect(ft.WidgetTester tester) {
    tester.expectKey(this);
  }

  String pwText(ft.WidgetTester tester) {
    return tester.widgetWithKey<PwText>(this).data;
  }

  void expectPwText(String text, ft.WidgetTester tester) {
    final actual = pwText(tester);

    ft.expect(actual, text);
  }

  void expectPwTextEndsWith(String text, ft.WidgetTester tester) {
    final actual = pwText(tester);

    ft.expect(
      actual.endsWith(text),
      ft.isTrue,
      reason: '$actual does not end with $text',
    );
  }

  Future<void> scrollUntilVisible(
    ft.WidgetTester tester, {
    required Key scrollable,
  }) {
    return tester.scrollUntilVisibleAndSettle(
      key: this,
      scrollable: scrollable,
    );
  }

  Future<int> drag(
    ft.WidgetTester tester, {
    required double dx,
    required double dy,
  }) async {
    await tester.drag(find.byKey(this), Offset(dx, dy));
    return tester.pumpAndSettle();
  }
}
