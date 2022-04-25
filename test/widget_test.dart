import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_blockchain_wallet/common/pw_design.dart';

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
