import 'package:decimal/decimal.dart';

class SendAsset {
  const SendAsset(
    this.displayDenom,
    this.exponent,
    this.denom,
    this.amount,
    this.fiatValue,
    this.imageUrl,
  );

  final String displayDenom;
  final int exponent;
  final String denom;
  final Decimal amount;
  final double fiatValue;
  final String imageUrl;

  String get displayAmount {
    return (amount / Decimal.fromInt(10).pow(exponent))
        .toDecimal(scaleOnInfinitePrecision: exponent)
        .toString();
  }

  String get displayFiatAmount {
    final scaledAmount = (amount / Decimal.fromInt(10).pow(exponent))
        .toDecimal(scaleOnInfinitePrecision: exponent);
    final conversionDecimal = Decimal.parse(fiatValue.toStringAsFixed(9));

    return "\$${(scaledAmount * conversionDecimal).toString()}";
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
      imageUrl,
    );
  }
}

class MultiSendAsset {
  MultiSendAsset(this.limit, this.fees);

  final SendAsset limit;
  final List<SendAsset> fees;

  String get displayAmount {
    final map = <String, SendAsset>{};
    map[limit.displayDenom] = limit;

    for (var fee in fees) {
      var current = map[fee.displayDenom];
      map[fee.displayDenom] = current?.copyWith(amount: fee.amount) ?? fee;
    }

    return map.entries
        .map((entry) => "${entry.value.displayAmount} ${entry.key}")
        .join(" + ");
  }
}
