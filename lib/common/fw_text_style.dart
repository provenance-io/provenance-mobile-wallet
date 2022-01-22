import 'package:flutter_tech_wallet/common/fw_design.dart';

/// Figma Typopgraphy Text Styles
enum FwTextStyle {
  h0,
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
  h7,
  m,
  mBold,
  s,
  sBold,
  xs,
  xsBold,
  caption,
  extraLarge,
}

mixin FwTextStyleMixin on Widget {
  FwTextStyle get style;

  TextStyle? textStyle(
    BuildContext context, {
    FwTextStyle? altStyle,
  }) {
    final theme = Theme.of(context);

    switch (altStyle ?? style) {
      case FwTextStyle.h0:
        return theme.textTheme.headline0;
      case FwTextStyle.h1:
        return theme.textTheme.headline1;
      case FwTextStyle.h2:
        return theme.textTheme.headline2;
      case FwTextStyle.h3:
        return theme.textTheme.headline3;
      case FwTextStyle.h4:
        return theme.textTheme.headline4;
      case FwTextStyle.h5:
        return theme.textTheme.headline5;
      case FwTextStyle.h6:
        return theme.textTheme.headline6;
      case FwTextStyle.h7:
        return theme.textTheme.headline7;
      case FwTextStyle.m:
        return theme.textTheme.medium;
      case FwTextStyle.mBold:
        return theme.textTheme.mediumBold;
      case FwTextStyle.s:
        return theme.textTheme.small;
      case FwTextStyle.sBold:
        return theme.textTheme.smallBold;
      case FwTextStyle.xs:
        return theme.textTheme.extraSmall;
      case FwTextStyle.xsBold:
        return theme.textTheme.extraSmallBold;
      case FwTextStyle.caption:
        return theme.textTheme.caption;
      case FwTextStyle.extraLarge:
        return theme.textTheme.extraLarge;
    }
  }
}
