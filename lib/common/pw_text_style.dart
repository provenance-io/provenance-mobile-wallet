import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/pw_theme.dart';

/// Provenance Typopgraphy Text Styles
enum PwTextStyle {
  h0,
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
  h7,
  m,
  m_p,
  mBold,
  mSemiBold,
  s,
  sSemiBold,
  sBold,
  xs,
  xsBold,
  caption,
  large,
  extraLarge,
  logo,
  subhead,
  body,
  headline2,
}

mixin PwTextStyleMixin on Widget {
  PwTextStyle get style;

  TextStyle? textStyle(
    BuildContext context, {
    PwTextStyle? altStyle,
  }) {
    final theme = Theme.of(context);

    switch (altStyle ?? style) {
      case PwTextStyle.h0:
        return theme.textTheme.headline0;
      case PwTextStyle.h1:
        return theme.textTheme.headline1;
      case PwTextStyle.h2:
        return theme.textTheme.headline2;
      case PwTextStyle.h3:
        return theme.textTheme.headline3;
      case PwTextStyle.h4:
        return theme.textTheme.headline4;
      case PwTextStyle.h5:
        return theme.textTheme.headline5;
      case PwTextStyle.h6:
        return theme.textTheme.headline6;
      case PwTextStyle.h7:
        return theme.textTheme.headline7;
      case PwTextStyle.m:
        return theme.textTheme.medium;
      case PwTextStyle.m_p:
        return theme.textTheme.pWMedium;
      case PwTextStyle.mBold:
        return theme.textTheme.mediumBold;
      case PwTextStyle.mSemiBold:
        return theme.textTheme.mediumSemiBold;
      case PwTextStyle.s:
        return theme.textTheme.small;
      case PwTextStyle.sSemiBold:
        return theme.textTheme.smallSemiBold;
      case PwTextStyle.sBold:
        return theme.textTheme.smallBold;
      case PwTextStyle.xs:
        return theme.textTheme.extraSmall;
      case PwTextStyle.xsBold:
        return theme.textTheme.extraSmallBold;
      case PwTextStyle.caption:
        return theme.textTheme.caption;
      case PwTextStyle.large:
        return theme.textTheme.large;
      case PwTextStyle.extraLarge:
        return theme.textTheme.extraLarge;
      case PwTextStyle.logo:
        return theme.textTheme.logo;
      case PwTextStyle.subhead:
        return theme.textTheme.subhead;
      case PwTextStyle.body:
        return theme.textTheme.body;
      case PwTextStyle.headline2:
        return theme.textTheme.provenanceHeadline2;
    }
  }
}
