import 'package:provenance_wallet/common/pw_design.dart';

/// Provenance Typopgraphy Text Styles
enum PwTextStyle {
  h3,
  h4,
  h6,
  m_p,
  xsBold,
  caption,
  large,
  logo,
  subhead,
  body,
  bodyBold,
  bodySmall,
  headline1,
  headline2,
  display1,
  display2,
  footnote,
  title,
}

mixin PwTextStyleMixin on Widget {
  PwTextStyle get style;

  TextStyle? textStyle(
    BuildContext context, {
    PwTextStyle? altStyle,
  }) {
    final theme = Theme.of(context);

    switch (altStyle ?? style) {
      case PwTextStyle.h3:
        return theme.textTheme.headline3;
      case PwTextStyle.h4:
        return theme.textTheme.headline4;
      case PwTextStyle.h6:
        return theme.textTheme.headline6;
      case PwTextStyle.m_p:
        return theme.textTheme.pWMedium;
      case PwTextStyle.xsBold:
        return theme.textTheme.extraSmallBold;
      case PwTextStyle.caption:
        return theme.textTheme.caption;
      case PwTextStyle.large:
      case PwTextStyle.logo:
        return theme.textTheme.logo;
      case PwTextStyle.subhead:
        return theme.textTheme.subhead;
      case PwTextStyle.body:
        return theme.textTheme.body;
      case PwTextStyle.bodySmall:
        return theme.textTheme.bodySmall;
      case PwTextStyle.headline2:
        return theme.textTheme.provenanceHeadline2;
      case PwTextStyle.headline1:
        return theme.textTheme.provenanceHeadline1;
      case PwTextStyle.bodyBold:
        return theme.textTheme.bodyBold;
      case PwTextStyle.display1:
        return theme.textTheme.display1;
      case PwTextStyle.display2:
        return theme.textTheme.display2;
      case PwTextStyle.footnote:
        return theme.textTheme.footnote;
      case PwTextStyle.title:
        return theme.textTheme.title;
    }
  }
}
