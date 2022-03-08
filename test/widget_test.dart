import 'package:provenance_wallet/common/pw_design.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Sample test', (WidgetTester tester) async {
    const text = 'test';

    await tester.pumpWidget(
      MaterialApp(
        home: Text(text),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(text), findsOneWidget);
  });
}
