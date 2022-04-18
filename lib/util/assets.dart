import 'package:flutter_svg/svg.dart';
import 'package:provenance_wallet/common/widgets/icon.dart';

class AssetPaths {
  static const images = Images();

  static SvgPicture getSvgPictureFrom({
    required String denom,
    double? size,
  }) =>
      SvgPicture.asset(
        AssetPaths._getImage(denom),
        width: size,
        height: size,
      );

  static String _getImage(String denom) {
    switch (denom.toUpperCase()) {
      case "USDF":
        return AssetPaths.images.usdf;
      case "INU":
        return AssetPaths.images.inu;
      case "ETF":
        return AssetPaths.images.etf;
      case "HASH":
      case "NHASH":
        return 'assets/${PwIcons.hashLogo}.svg';
      default:
        return 'assets/${PwIcons.provenance}.svg';
    }
  }
}

class Images {
  const Images();

  final String background = 'assets/images/background.png';
  final String coins = "assets/images/coins.png";
  final String connectionRequest = 'assets/images/connection_request.png';
  final String transactionComplete = 'assets/images/transaction_complete.png';
  final String createPassphrase = 'assets/images/savePassphrase.png';
  final String recoverAccount = 'assets/images/recoverAccount.png';
  final String backupComplete = 'assets/images/backupComplete.png';
  final String walletFinished = 'assets/images/walletFinished.png';
  final String etf = 'assets/images/etf.svg';
  final String usdf = 'assets/images/usdf.svg';
  final String inu = 'assets/images/inu.svg';
  final String warning = 'assets/images/warning.png';
  final String bigHash = 'assets/images/bigHash.png';
}
