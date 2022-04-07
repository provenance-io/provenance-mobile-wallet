import 'package:intl/intl.dart';

extension DoubleExtensions on double {
  String toCurrency({showCents = true}) =>
      NumberFormat.simpleCurrency(decimalDigits: showCents ? null : 0)
          .format(this);

  int toCoinAmount() => (this * 100).round();
}
