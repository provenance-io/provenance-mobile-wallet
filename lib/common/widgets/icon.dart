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
  static const String staking = 'staking';
  static const String hashLogo = 'hash_logo';
  static const String copy = 'copy';
  static const String userAccount = 'user_account';
  static const String downArrow = 'down_arrow';
  static const String upArrow = 'up_arrow';
  static const String caret = 'caret';
  static const String remove = 'remove';
  static const String chevron = 'chevron';
  static const String newWindow = "new_window";
  static const String provenance = "provenance";
  static const String faceId = "face_id";
  static const String touchId = "touch_id";
  static const String dashboard = "dashboard";
  static const String ellipsis = "ellipsis";
  static const String qr = "qr";
  static const String check = "check";
  static const String linked = "linked";
  static const String warn = 'warn';
  static const String plus = 'plus';
  static const String minus = 'minus';
  static const String edit = 'edit';
  static const String circleChecked = 'circle_checked';
  static const String circleUnchecked = 'circle_unchecked';
}

class PwIcon extends StatelessWidget {
  const PwIcon(
    this.icon, {
    Key? key,
    this.color,
    double? size,
  })  : width = size,
        height = size,
        super(key: key);

  const PwIcon.only(
    this.icon, {
    Key? key,
    this.color,
    this.width,
    this.height,
  }) : super(key: key);

  final String icon;

  final Color? color;

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/$icon.svg',
      width: width,
      height: height,
      color: color ?? IconTheme.of(context).color,
    );
  }
}
