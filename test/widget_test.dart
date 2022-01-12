import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Sample test', (WidgetTester tester) async {
    final text = 'test';

    await tester.pumpWidget(
      MaterialApp(
        home: Text(text),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(text), findsOneWidget);
  });
}
