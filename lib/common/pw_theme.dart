import 'package:flutter/material.dart';

class ProvenanceThemeData {
  /// ----- PROVENANCE COLORS -----
  // Keep private. Expose only through colorScheme or ThemeData.
  /// Greys
  static const Color _neutral800 = Color(0xFF09090C);
  static const Color _neutral750 = Color(0xFF1A1C23);
  static const Color _neutral700 = Color(0xFF2C2F3A);
  static const Color _neutral550 = Color(0xFF464B5D);
  static const Color _neutral500 = Color(0xFF4C5165);
  static const Color _neutral250 = Color(0xFFA2A7B9);

  // Page Indicator
  static const Color _indicatorActive = Color(0xFFF3F4F6);
  static const Color _indicatorInActive = Color(0xFF8B90A7);

  /// Primary
  static const Color _primary2 = Color(0xFF1B66EA);

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
    fontSize: 21,
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
    letterSpacing: 29 * 0.04,
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
    //height: 22.4 / 14,
    //letterSpacing: 22 * 0.04,
  );
  static const TextStyle _footnote = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 19.2 / 12,
    letterSpacing: 19 * 0.04,
  );
}

extension CustomColorScheme on ColorScheme {
  Color get provenanceNeutral800 => ProvenanceThemeData._neutral800;
  Color get provenanceNeutral750 => ProvenanceThemeData._neutral750;
  Color get provenanceNeutral700 => ProvenanceThemeData._neutral700;
  Color get provenanceNeutral550 => ProvenanceThemeData._neutral550;
  Color get provenanceNeutral500 => ProvenanceThemeData._neutral500;
  Color get provenanceNeutral250 => ProvenanceThemeData._neutral250;

  Color get logo => ProvenanceThemeData._provenanceLogo;
  Color get primaryP500 => ProvenanceThemeData._primary2;

  Color get indicatorActive => ProvenanceThemeData._indicatorActive;
  Color get indicatorInActive => ProvenanceThemeData._indicatorInActive;
  Color get secondary700 => ProvenanceThemeData._secondary700;
  Color get secondary400 => ProvenanceThemeData._secondary400;
  Color get error => ProvenanceThemeData._error;
}

extension CustomTextTheme on TextTheme {
  TextStyle get pWMedium => ProvenanceThemeData._medium;
  TextStyle get large =>
      ProvenanceThemeData._logo.copyWith(fontWeight: FontWeight.w600);
  TextStyle get logo => ProvenanceThemeData._logo;
  TextStyle get subhead => ProvenanceThemeData._subhead;
  TextStyle get body => ProvenanceThemeData._body;
  TextStyle get bodyBold => ProvenanceThemeData._bodyBold;
  TextStyle get provenanceHeadline2 => ProvenanceThemeData._headline2;
}
