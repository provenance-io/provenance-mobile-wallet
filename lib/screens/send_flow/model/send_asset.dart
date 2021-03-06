import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';

class SendAsset {
  const SendAsset(
    this.displayDenom,
    this.exponent,
    this.denom,
    this.amount,
    this.fiatValue,
  );

  SendAsset.nhash(Decimal amount, [double price = 0])
      : this(
          "hash",
          9,
          "nhash",
          amount,
          price,
        );

  final String displayDenom;
  final int exponent;
  final String denom;
  final Decimal amount;
  final double fiatValue;

  String get displayAmount {
    return (amount / Decimal.fromInt(10).pow(exponent))
        .toDecimal(scaleOnInfinitePrecision: exponent)
        .toString();
  }

  String get displayFiatAmount {
    final conversionDecimal = Decimal.parse(fiatValue.toString()) * amount;
    final numberFormatter = NumberFormat.simpleCurrency(decimalDigits: null);

    return numberFormatter.format(DecimalIntl(conversionDecimal));
  }

  SendAsset copyWith({
    required Decimal amount,
  }) {
    return SendAsset(
      displayDenom,
      exponent,
      denom,
      amount,
      fiatValue,
    );
  }
}

class MultiSendAsset {
  MultiSendAsset(
    this.estimate,
    this.fees,
  );

  final int estimate;
  final List<SendAsset> fees;

  String get displayAmount {
    final map = <String, SendAsset>{};
    map['nhash'] = SendAsset(
      "Hash",
      9,
      'nhash',
      Decimal.fromInt(estimate),
      0,
    );
    for (var fee in fees) {
      var current = map[fee.denom];
      final total = (current?.amount ?? Decimal.zero) + fee.amount;

      map[fee.denom] = current?.copyWith(amount: total) ?? fee;
    }

    return map.values
        .map((e) => "${e.displayAmount} ${e.displayDenom}")
        .join(" + ");
  }
}
