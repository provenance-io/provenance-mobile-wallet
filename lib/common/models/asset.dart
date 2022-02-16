import 'package:provenance_wallet/common/widgets/icon.dart';
import 'package:provenance_wallet/network/models/asset_response.dart';
import 'package:provenance_wallet/util/assets.dart';

class Asset {
  Asset({required AssetResponse dto})
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
        exponent = dto.exponent!;

  Asset.fake({
    required this.denom,
    required this.amount,
    required this.display,
    required this.description,
    required this.exponent,
    required this.displayAmount,
  });

  final String denom;
  final String amount;
  final String display;
  final String description;
  final int exponent;
  final String displayAmount;

  String get image {
    switch (display) {
      case "USDF":
        return AssetPaths.images.usdf;
      case "INU":
        return AssetPaths.images.inu;
      case "ETF":
        return AssetPaths.images.etf;
      default:
        return PwIcons.hashLogo;
    }
  }
}
