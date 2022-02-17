import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// All the Icons for Figure Tech Wallet. Imported from Figma SVGs.
///
/// TODO: Remove these classes in favor of icon data:
/// Ideally, we can deprecate [PwIcon] by creating a custom font using
/// http://fluttericon.com and simply using the icons as IconData, like so:
/// ```dart
/// Icon(FigureIcons.creditCard);
/// ```
///

class PwIcons {
  static const String back = 'back';
  static const String close = 'close';
  static const String scanCode = '2d_code';
  static const String staking = 'staking';
  static const String wallet = 'wallet';
  static const String faceScan = 'face_scan';
  static const String hashLogo = 'hash_logo';
  static const String copy = 'copy';
  static const String walletConnect = 'wallet_connect';
  static const String userAccount = 'user_account';
  static const String downArrow = 'down_arrow';
  static const String upArrow = 'up_arrow';
  static const String caret = 'caret';
  static const String dollarIcon = 'dollar_icon';
  static const String menuIcon = 'menu_icon';
  static const String plus = 'plus';
  static const String remove = 'remove';
  static const String chevron = 'chevron';
  static const String new_window = "new_window";
  static const String provenance = "provenance";
  static const String face_id = "face_id";
  static const String dashboard = "dashboard";
  static const String ellipsis = "ellipsis";
  static const String qr = "qr";
  static const String check = "check";
}

class PwIcon extends StatelessWidget {
  const PwIcon(
    this.icon, {
    Key? key,
    this.color,
    this.size,
  }) : super(key: key);

  final String icon;

  final Color? color;

  final double? size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/$icon.svg',
      width: size,
      height: size,
      color: color ?? IconTheme.of(context).color,
    );
  }
}
