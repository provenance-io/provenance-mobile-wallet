import 'dart:math';

import 'package:intl/intl.dart';
import 'package:provenance_wallet/services/asset_client/dtos/asset_dto.dart';
import 'package:provenance_wallet/util/extensions/double_extensions.dart';

class Asset {
  Asset({required AssetDto dto})
      : assert(dto.amount != null),
        assert(dto.denom != null),
        assert(dto.description != null),
        assert(dto.display != null),
        assert(dto.displayAmount != null),
        assert(dto.exponent != null),
        denom = dto.denom!,
        amount = dto.amount!,
        display = dto.display!.toUpperCase(),
        displayAmount = dto.displayAmount!,
        description = dto.description!,
        exponent = dto.exponent!,
        usdPrice = dto.usdPrice ?? 0,
        dailyHigh = dto.dailyHigh,
        dailyLow = dto.dailyLow,
        dailyVolume = dto.dailyVolume;

  Asset.fake({
    required this.denom,
    required this.amount,
    required this.display,
    required this.description,
    required this.exponent,
    required this.displayAmount,
    required this.usdPrice,
    this.dailyHigh,
    this.dailyLow,
    this.dailyVolume,
  });

  final String denom;
  final String amount;
  final String display;
  final String description;
  final int exponent;
  final String displayAmount;
  final double usdPrice;
  final double? dailyHigh;
  final double? dailyLow;
  final double? dailyVolume;

  String get formattedAmount {
    return (usdPrice * double.parse(amount)).toCurrency();
  }

  String get formattedUsdPrice {
    final formatter = NumberFormat.simpleCurrency();
    final scaledNumber = (usdPrice * pow(10, exponent));

    return formatter.format(scaledNumber);
  }
}
