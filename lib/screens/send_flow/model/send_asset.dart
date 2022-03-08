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
  final String fiatValue;
  final String imageUrl;

  String get displayAmount {
    return (amount / Decimal.fromInt(10).pow(exponent))
        .toDecimal(scaleOnInfinitePrecision: exponent)
        .toString();
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
