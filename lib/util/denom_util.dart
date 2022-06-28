import 'package:decimal/decimal.dart';

const _hashExponent = 9;
final _ten = Decimal.fromInt(10);

BigInt hashToNHash(Decimal hash) {
  return toBase(hash, _hashExponent);
}

Decimal nHashToHash(BigInt nHash) {
  return toDisplay(nHash, _hashExponent);
}

BigInt toBase(Decimal display, int exponent) {
  if (display.scale > exponent) {
    throw ArgumentError.value(display, 'display',
        'Scale ${display.scale} is greater than exponent $exponent');
  }

  final basePerDisplay = _ten.pow(exponent);

  return (display * basePerDisplay).toBigInt();
}

Decimal toDisplay(BigInt base, int exponent) {
  final basePerDisplay = _ten.pow(exponent);

  return (Decimal.fromBigInt(base) / basePerDisplay)
      .toDecimal(scaleOnInfinitePrecision: exponent);
}
