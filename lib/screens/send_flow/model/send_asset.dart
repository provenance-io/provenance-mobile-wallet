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

  SendAsset.nhash(Decimal amount, [double price = 0])
      : this(
          "hash",
          9,
          "nhash",
          amount,
          price,
          "",
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

    return "\$${(amount * conversionDecimal).toStringAsFixed(2)}";
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
      "",
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
