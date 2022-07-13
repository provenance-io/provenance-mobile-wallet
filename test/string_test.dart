import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/util/address_util.dart';

void main() {
  test('Abbreviate max length string returns original', () {
    const original = 'abcdefghijk';
    final actual = abbreviateAddress(original);

    expect(actual, original);
  });

  test('Abbreviate greater than max length string abbreviates', () {
    const original = 'abcdefghijklmnopqrs';
    const expected = 'abc...lmnopqrs';
    final actual = abbreviateAddress(original);

    expect(actual, expected);
  });
}
