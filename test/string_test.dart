import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_blockchain_wallet/util/strings.dart';

void main() {
  test('Abbreviate max length string returns original', () {
    const original = 'abcdefghijk';
    final actual = original.abbreviateAddress();

    expect(actual, original);
  });

  test('Abbreviate greater than max length string abbreviates', () {
    const original = 'abcdefghijklmnopqrs';
    const expected = 'abc...lmnopqrs';
    final actual = original.abbreviateAddress();

    expect(actual, expected);
  });
}
