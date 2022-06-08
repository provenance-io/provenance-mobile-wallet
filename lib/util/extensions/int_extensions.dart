import 'package:decimal/decimal.dart';

extension IntExtension on int {
  num nhashToHash({int? fractionDigits}) {
    final decimal = (Decimal.fromInt(this) / Decimal.fromInt(10).pow(9))
        .toDecimal(scaleOnInfinitePrecision: 9);
    if (fractionDigits != null) {
      return num.tryParse(decimal.toStringAsFixed(fractionDigits)) ?? 0;
    }
    return num.tryParse(decimal.toString()) ?? 0;
  }
}
