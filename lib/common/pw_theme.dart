import 'package:flutter/material.dart';

class ProvenanceThemeData {
  /// ----- PROVENANCE COLORS -----
  // Keep private. Expose only through colorScheme or ThemeData.
  /// Greys
  static const Color _globalNeutral500 = Color(0xFF4C5165);

  // Page Indicator
  static const Color _indicatorActive = Color(0xFFF3F4F6);
  static const Color _indicatorInActive = Color(0xFF8B90A7);

  /// Primary
  static const Color _primary1 = Color(0xFF3F80F3);
  static const Color _primary2 = Color(0xFF1B66EA);

  /// Secondary
  static const Color _secondary400 = Color(0xFF03B5B2);

  // ----- PROVENANCE TYPOGRAPHY -----
  // Keep private. Expose only through ThemeData.

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
}

extension CustomColorScheme on ColorScheme {
  Color get provenanceNeutral500 => ProvenanceThemeData._globalNeutral500;

  Color get primaryP1 => ProvenanceThemeData._primary1;
  Color get primaryP500 => ProvenanceThemeData._primary2;

  Color get indicatorActive => ProvenanceThemeData._indicatorActive;
  Color get indicatorInActive => ProvenanceThemeData._indicatorInActive;
  Color get secondary400 => ProvenanceThemeData._secondary400;
}

extension CustomTextTheme on TextTheme {
  TextStyle get pWMedium => ProvenanceThemeData._medium;
  TextStyle get large =>
      ProvenanceThemeData._logo.copyWith(fontWeight: FontWeight.w600);
  TextStyle get logo => ProvenanceThemeData._logo;
}
