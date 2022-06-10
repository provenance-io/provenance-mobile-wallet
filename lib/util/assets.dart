import 'package:flutter_svg/svg.dart';
import 'package:provenance_wallet/common/widgets/icon.dart';

class Assets {
  static const imagePaths = ImagePaths();

  static SvgPicture getSvgPictureFrom({
    required String denom,
    double? size,
  }) =>
      SvgPicture.asset(
        Assets._getImage(denom),
        width: size,
        height: size,
      );

  static String _getImage(String denom) {
    switch (denom.toUpperCase()) {
      case "USDF":
        return Assets.imagePaths.usdf;
      case "INU":
        return Assets.imagePaths.inu;
      case "ETF":
        return Assets.imagePaths.etf;
      case "HASH":
      case "NHASH":
        return 'assets/${PwIcons.hashLogo}.svg';
      default:
        return 'assets/${PwIcons.provenance}.svg';
    }
  }
}

class ImagePaths {
  const ImagePaths();

  final String background = 'assets/images/background.png';
  final String coins = "assets/images/coins.png";
  final String connectionRequest = 'assets/images/connection_request.png';
  final String transactionComplete = 'assets/images/transaction_complete.png';
  final String createPassphrase = 'assets/images/savePassphrase.png';
  final String recoverAccount = 'assets/images/recoverAccount.png';
  final String backupComplete = 'assets/images/backupComplete.png';
  final String accountFinished = 'assets/images/accountFinished.png';
  final String multiSigInvite = 'assets/images/multi_sig_invite.png';
  final String etf = 'assets/images/etf.svg';
  final String usdf = 'assets/images/usdf.svg';
  final String inu = 'assets/images/inu.svg';
  final String warning = 'assets/images/warning.png';
  final String bigHash = 'assets/images/bigHash.png';
}
