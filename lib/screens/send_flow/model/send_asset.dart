import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';
import 'package:provenance_wallet/gas_fee_estimate.dart';
import 'package:provenance_wallet/util/constants.dart';

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
          nHashDenom,
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
    this.assets,
  );

  final GasFeeEstimate estimate;
  final List<SendAsset> assets;

  String get displayAmount {
    final map = <String, SendAsset>{};
    map[nHashDenom] = SendAsset(
      "Hash",
      9,
      nHashDenom,
      Decimal.fromInt(estimate.units),
      0,
    );
    for (var fee in assets) {
      var current = map[fee.denom];
      final total = (current?.amount ?? Decimal.zero) + fee.amount;

      map[fee.denom] = current?.copyWith(amount: total) ?? fee;
    }

    return map.values
        .map((e) => "${e.displayAmount} ${e.displayDenom}")
        .join(" + ");
  }
}
