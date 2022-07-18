import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/util/denom_util.dart';

void main() {
  final nHashPerHash = BigInt.from(1000000000);

  test('Converts to one hash', () {
    final hash = nHashToHash(nHashPerHash);

    expect(hash, Decimal.one);
  });

  test('Converts from one hash', () {
    final nHash = hashToNHash(Decimal.one);

    expect(nHash, nHashPerHash);
  });

  test('Decimal scales to precision length of exponent', () {
    final nHash = BigInt.from(123456789);
    final hash = nHashToHash(nHash);

    expect(hash, Decimal.parse('0.123456789'));
  });

  test('String to Decimal scales to decimal length', () {
    final hash = stringNHashToHash('123456789', fractionDigits: 4);

    expect(hash, Decimal.parse('0.1235'));
  });

  test('Decimal scale greater than exponent throws', () {
    final hash = Decimal.parse('1.1234567891');

    expect(() => hashToNHash(hash), throwsArgumentError);
  });
}
