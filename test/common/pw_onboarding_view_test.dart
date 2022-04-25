import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_blockchain_wallet/common/pw_onboarding_view.dart';
import 'package:provenance_blockchain_wallet/common/widgets/pw_spacer.dart';

main() {
  Future<void> _build(
    WidgetTester tester,
    List<Widget> children,
    double bottomOffset, [
    Size? desiredPhysicalSize,
  ]) {
    if (desiredPhysicalSize != null) {
      final ratio = tester.binding.window.devicePixelRatio;
      tester.binding.window.physicalSizeTestValue = Size(
        ratio * desiredPhysicalSize.width,
        ratio * desiredPhysicalSize.height,
      );
    }

    return tester.pumpWidget(
      MaterialApp(
        home: PwOnboardingView(
          children: children,
          bottomOffset: bottomOffset,
        ),
      ),
    );
  }

  test('verify default bottom offset', () {
    final onBoardingView = PwOnboardingView(children: [Container()]);
    expect(onBoardingView.bottomOffset, Spacing.largeX6 + Spacing.largeX5);
  });

  testWidgets("Content is larget than scrollable area", (tester) async {
    final children = [
      Container(
        height: 500,
      ),
    ];

    await _build(
      tester,
      children,
      50,
      Size(320, 400),
    );
    await tester.pumpAndSettle();

    final verticalFind = find.byType(VerticalSpacer);
    expect(tester.getSize(verticalFind).height, 0);

    // final scrollFind = find.byType(SingleChildScrollView);
    // final scrollView = tester.widget<SingleChildScrollView>(scrollFind);

    // expect(scrollView., 100);
  });

  testWidgets(
    "Content is smaller than scrollable area, but does not allow full bottom padding",
    (tester) async {
      final children = [
        Container(
          height: 500,
        ),
      ];

      await _build(
        tester,
        children,
        200,
        Size(320, 600),
      );

      await tester.pumpAndSettle();

      final verticalFind = find.byType(VerticalSpacer);

      expect(
        tester.getSize(verticalFind).height,
        100,
      );
    },
  );

  testWidgets(
    "Content is smaller than scrollable area with enough room for desired padding",
    (tester) async {
      final children = [
        Container(
          height: 500,
        ),
      ];

      await _build(
        tester,
        children,
        50,
        Size(320, 600),
      );

      await tester.pumpAndSettle();

      final verticalFind = find.byType(VerticalSpacer);

      expect(
        tester.getSize(verticalFind).height,
        50,
      );
    },
  );
}
