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
    final conversionDecimal = Decimal.parse(fiatValue.toString());

    return "\$${(amount * conversionDecimal).toStringAsFixed(9)}";
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
    map[limit.denom] = limit;

    for (var fee in fees) {
      var current = map[fee.denom];
      map[fee.denom] = current?.copyWith(amount: fee.amount) ?? fee;
    }

    return map.entries
        .map((entry) =>
            "${entry.value.displayAmount} ${entry.value.displayDenom}")
        .join(" + ");
  }
}
