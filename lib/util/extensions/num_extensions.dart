import 'package:decimal/decimal.dart';

extension NumExtensions on num {
  String nhashFromHash() {
    return (Decimal.parse(toString()) * Decimal.fromInt(10).pow(9)).toString();
  }
}
