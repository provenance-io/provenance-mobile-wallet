import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/util/strings.dart';

void main() {
  test('Abbreviate max length string returns original', () {
    final original = 'abcdefghijklmnopqr';
    final actual = original.abbreviateAddress();

    expect(actual, original);
  });

  test('Abbreviate greater than max length string abbreviates', () {
    final original = 'abcdefghijklmnopqrs';
    final expected = 'abcdefghij.....qrs';
    final actual = original.abbreviateAddress();

    expect(actual, expected);
  });
}
