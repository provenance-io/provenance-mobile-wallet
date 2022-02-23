import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProvenanceThemeData {
  /// ----- PROVENANCE COLORS -----
  // Keep private. Expose only through colorScheme or ThemeData.
  /// Greys
  static const Color _neutral800 = Color(0xFF09090C);
  static const Color _neutral750 = Color(0xFF1A1C23);
  static const Color _neutral700 = Color(0xFF2C2F3A);
  static const Color _neutral600 = Color(0xFF3D4151);
  static const Color _neutral550 = Color(0xFF464B5D);
  static const Color _neutral500 = Color(0xFF4C5165);
  static const Color _neutral450 = Color(0xFF585D74);
  static const Color _neutral250 = Color(0xFFA2A7B9);
  static const Color _neutral200 = Color(0xFFB9BDCA);
  static const Color _neutral50 = Color(0xFFF3F4F6);
  static const Color _neutralNeutral = Color(0xFFFFFFFF);
  // Page Indicator
  static const Color _indicatorActive = Color(0xFFF3F4F6);
  static const Color _indicatorInActive = Color(0xFF8B90A7);

  /// Primary
  static const Color _primary700 = Color(0xFF022460);
  static const Color _primary650 = Color(0xFF01368F);
  static const Color _primary500 = Color(0xFF357EFD);
  static const Color _primary550 = Color(0xFF1B66EA);
  static const Color _primary400 = Color(0xFF70A9FF);

  /// Secondary
  static const Color _secondary400 = Color(0xFF03B5B2);
  static const Color _secondary700 = Color(0xFF013C3B);

  static const Color _provenanceLogo = Color(0xFF3F80F3);

  static const Color _error = Color(0xFFED6E74);

  // ----- PROVENANCE TYPOGRAPHY -----
  // Keep private. Expose only through ThemeData.

  // Landing Page TextStyles
  static const TextStyle _headline3 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 37.68,
    fontWeight: FontWeight.w300,
    height: 45.93 / 37.68,
  );

  static const TextStyle _headline4 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 24,
    fontWeight: FontWeight.w300,
    height: 29.26 / 24.0,
  );

  static const TextStyle _logo = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 19.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 10,
  );

  static const TextStyle _medium = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
    letterSpacing: 0.32,
  );
  static const TextStyle _display1 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 44,
    fontWeight: FontWeight.w300,
    height: 53.64 / 44,
    letterSpacing: 54 * 0.02,
  );
  static const TextStyle _display2 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 38,
    fontWeight: FontWeight.w300,
    height: 46.32 / 38,
    letterSpacing: 46 * 0.02,
  );
  static const TextStyle _displayBody = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24.8 / 16,
    letterSpacing: 25 * 0.04,
  );
  static const TextStyle _headline1 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 25.6 / 21,
    letterSpacing: 31 * 0.32,
  );
  static const TextStyle _headline2 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    height: 25.6 / 21,
    letterSpacing: 20 * 0.32,
  );
  static const TextStyle _title = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 28.8 / 18,
    //letterSpacing: 29 * 0.04,
  );
  static const TextStyle _body = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 22.4 / 14,
  );
  static const TextStyle _bodyBold = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle _subhead = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 22.4 / 14,
    letterSpacing: 14 * 0.04,
  );
  static const TextStyle _footnote = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 19.2 / 12,
    //letterSpacing: 19 * 0.04,
  );

  static const _colorScheme = ColorScheme(
    primary: _primary500,
    primaryVariant: _primary550,
    secondary: _secondary400,
    secondaryVariant: _secondary400,
    background: _neutral750,
    surface: _neutral50,
    onBackground: _neutralNeutral,
    onSurface: _neutralNeutral,
    error: _error,
    onError: _neutralNeutral,
    onPrimary: _neutralNeutral,
    onSecondary: _neutralNeutral,
    brightness: Brightness.light,
  );

  static final TextTheme _textTheme = TextTheme(
    headline1: _headline1,
    headline2: _headline2,
    headline3: _headline3,
    headline4: _headline4,
    headline5: _display1,
    headline6: _display2,
    subtitle1: _medium,
    subtitle2: _displayBody,
    bodyText1: _body,
    bodyText2: _bodyBold,
    button: _bodyBold,
    caption: _footnote,
    // STYLES NOT DEFINED
    overline: _body.copyWith(color: _error),
  );

  static final themeData = ThemeData(
    colorScheme: _colorScheme,
    appBarTheme: AppBarTheme(
      color: _colorScheme.primaryP500,
      iconTheme: IconThemeData(color: _colorScheme.onPrimary),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: _colorScheme.primary,
    ),
    canvasColor: _colorScheme.background,
    toggleableActiveColor: _colorScheme.primaryP500,
    highlightColor: Colors.transparent,
    indicatorColor: _colorScheme.primaryP500,
    primaryColor: _colorScheme.primaryP500,
    backgroundColor: _neutral750,
    scaffoldBackgroundColor: _colorScheme.background,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: _neutral750,
      behavior: SnackBarBehavior.floating,
    ),
    typography: Typography.material2018(
      platform: defaultTargetPlatform,
    ),
    textTheme: _textTheme.apply(
      bodyColor: _neutralNeutral,
      displayColor: _neutralNeutral,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        // unfortunately for some reason this color gets overriden with primary (bug?)
        // have to set in input implentation
        borderSide: BorderSide(color: _colorScheme.midGrey),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
    ),
    unselectedWidgetColor: _colorScheme.lightGrey,
    tabBarTheme: TabBarTheme(
      labelColor: _colorScheme.primary,
      unselectedLabelColor: _neutral550,
      labelStyle: _medium,
      unselectedLabelStyle: _medium,
    ),
    dividerColor: _neutral600,
  );
}

class FigurePayThemeData {
  // ----- FIGMA TYPOGRAPHY -----
  // Keep private. Expose only through ThemeData.

  static const TextStyle _small = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 12,
    fontWeight: FontWeight.w300,
    height: 15.72 / 12.0,
    letterSpacing: 0.32,
  );
}

extension CustomColorScheme on ColorScheme {
  Color get light => ProvenanceThemeData._error;
  Color get lightGrey => ProvenanceThemeData._error;
  Color get midGrey => ProvenanceThemeData._error;
  Color get black => ProvenanceThemeData._error;
  Color get positive => ProvenanceThemeData._error;
  Color get darkGrey => ProvenanceThemeData._error;
  Color get otherBackground => ProvenanceThemeData._error;

// Provenance themes
  Color get neutral800 => ProvenanceThemeData._neutral800;
  Color get neutral750 => ProvenanceThemeData._neutral750;
  Color get neutral700 => ProvenanceThemeData._neutral700;
  Color get neutral600 => ProvenanceThemeData._neutral600;
  Color get neutral550 => ProvenanceThemeData._neutral550;
  Color get neutral500 => ProvenanceThemeData._neutral500;
  Color get neutral450 => ProvenanceThemeData._neutral450;
  Color get neutral250 => ProvenanceThemeData._neutral250;
  Color get neutral200 => ProvenanceThemeData._neutral200;
  Color get neutral50 => ProvenanceThemeData._neutral50;
  Color get neutralNeutral => ProvenanceThemeData._neutralNeutral;

  Color get logo => ProvenanceThemeData._provenanceLogo;
  Color get primary700 => ProvenanceThemeData._primary700;
  Color get primaryP650 => ProvenanceThemeData._primary650;
  Color get primaryP550 => ProvenanceThemeData._primary550;
  Color get primaryP500 => ProvenanceThemeData._primary500;
  Color get primary400 => ProvenanceThemeData._primary400;

  Color get indicatorActive => ProvenanceThemeData._indicatorActive;
  Color get indicatorInActive => ProvenanceThemeData._indicatorInActive;
  Color get secondary400 => ProvenanceThemeData._secondary400;
  Color get secondary700 => ProvenanceThemeData._secondary700;
  Color get error => ProvenanceThemeData._error;
}

extension CustomTextTheme on TextTheme {
  TextStyle get mediumBold => FigurePayThemeData._small;
  TextStyle get medium => FigurePayThemeData._small;
  TextStyle get smallBold => FigurePayThemeData._small;
  TextStyle get small => FigurePayThemeData._small;
  TextStyle get extraSmallBold => FigurePayThemeData._small;
  TextStyle get extraSmall => FigurePayThemeData._small;
  TextStyle get headline7 => FigurePayThemeData._small;
  TextStyle get extraLarge => FigurePayThemeData._small;

// Provenance themes
  TextStyle get pWMedium => ProvenanceThemeData._medium;
  TextStyle get large =>
      ProvenanceThemeData._logo.copyWith(fontWeight: FontWeight.w600);
  TextStyle get logo => ProvenanceThemeData._logo;
  TextStyle get subhead => ProvenanceThemeData._subhead;
  TextStyle get body => ProvenanceThemeData._body;
  TextStyle get bodyBold => ProvenanceThemeData._bodyBold;
  TextStyle get provenanceHeadline2 => ProvenanceThemeData._headline2;
  TextStyle get provenanceHeadline1 => ProvenanceThemeData._headline1;
  TextStyle get display1 => ProvenanceThemeData._display1;
  TextStyle get display2 => ProvenanceThemeData._display2;
  TextStyle get footnote => ProvenanceThemeData._footnote;
  TextStyle get title => ProvenanceThemeData._title;
}
