import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FigurePayThemeData {
  /// ----- FIGMA COLORS -----
  // Keep private. Expose only through colorScheme or ThemeData.
  /// Greys
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _light = Color(0xFFF9F9F9);
  static const Color _otherBackground = Color(0xFFE5E5E5);
  static const Color _lightGrey = Color(0xFFE4E5EB);
  static const Color _midGrey = Color(0xFFCCCDD3);
  static const Color _grey = Color(0xFF797E92);
  static const Color _darkGrey = Color(0xFF4C5165);
  static const Color _black = Color(0xFF05010C);
  static const Color _globalNeutral550 = Color(0xFF3D4151);
  static const Color _globalNeutral450 = Color(0xFF555B71);
  static const Color _globalNeutral400 = Color(0xFF6A7187);
  static const Color _globalNeutral600Black = Color(0xFF30323F);
  static const Color _globalNeutral350 = Color(0xFF9196AA);
  static const Color _globalNeutral500 = Color(0xFF4C5165);
  static const Color _iconColor = Color(0xFFF5F7FD);
  static const Color _globalNeutral250 = Color(0xFFC9CFE3);
  static const Color _globalNeutral50 = Color(0xFFF9FCFF);
  static const Color _globalNeutral150 = Color(0xFFE9EEF9);

  /// Functional
  static const Color _positive = Color(0xFF4ABB0B);
  static const Color _error = Color(0xFFE01B25);
  static const Color _warning = Color(0xFFFEC82A);
  static const Color _systemGreen = Color(0xFF34C759);
  // Picker
  static const Color _pickerGrey = Color(0xFF696969);
  static const Color _pickerBlack = Color(0xFF474749);

  /// Primary
  static const Color _primary1 = Color(0xFF190050);
  static const Color _primary2 = Color(0xFF42368E);
  static const Color _primary3 = Color(0xFF432BBA);
  static const Color _primary4 = Color(0xFF5339D7);
  static const Color _primary5 = Color(0xFF7E6DD6);
  static const Color _primary6 = Color(0xFFDDD8FD);
  static const Color _primary7 = Color(0xFF573AE6);
  static const Color _primary550 = Color(0xFF1B66EA);

  /// Secondary
  static const Color _secondary1 = Color(0xFF28CEA8);
  static const Color _secondary2 = Color(0xFF2BBAA0);

  /// Accent
  static const Color _lime = Color(0xFFDBF72C);

  // ----- FIGMA TYPOGRAPHY -----
  // Keep private. Expose only through ThemeData.
  static const TextStyle _headline0 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 50,
    fontWeight: FontWeight.w700,
    height: 45.0 / 50.0,
  );

  static const TextStyle _headline1 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 44,
    fontWeight: FontWeight.w700,
    height: 39.6 / 44.0,
  );

  static const TextStyle _headline2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 39.6 / 40.0,
  );

  static const TextStyle _headline3 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 40.8 / 30.0,
  );

  static const TextStyle _headline4 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 23.54 / 22.0,
  );

  static const TextStyle _headline5 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 24.4 / 20.0,
  );

  static const TextStyle _headline6 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 24.48 / 18.0,
  );

  static const TextStyle _headline7 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 16.0 / 15.0,
  );

  static const TextStyle _extraLarge = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 25,
    fontWeight: FontWeight.w400,
    height: 15.55 / 15.0,
    letterSpacing: 0.32,
  );

  static const TextStyle _medium = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 16,
    fontWeight: FontWeight.w300,
    height: 15.55 / 15.0,
    letterSpacing: 0.32,
  );

  static const TextStyle _mediumBold = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 23.1 / 15.0,
    letterSpacing: 0.32,
  );

  static const TextStyle _mediumSemiBold = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24.48 / 15.0,
    letterSpacing: 0.32,
  );

  static const TextStyle _small = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 12,
    fontWeight: FontWeight.w300,
    height: 15.72 / 12.0,
    letterSpacing: 0.32,
  );

  static const TextStyle _smallSemiBold = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 12.8,
    fontWeight: FontWeight.w500,
    height: 15.72 / 12.0,
    letterSpacing: 0.32,
  );

  static const TextStyle _smallBold = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 17.72 / 12.0,
    letterSpacing: 0.32,
  );

  static const TextStyle _extraSmall = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 15.6 / 10.0,
    letterSpacing: 0.32,
  );

  static const TextStyle _extraSmallBold = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 15.6 / 10.0,
    letterSpacing: 0.32,
  );

  // Fallback style should show red so we can see which widgets need fixed.
  static const TextStyle _fallback = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 15.6 / 10.0,
    letterSpacing: 0.32,
    color: Colors.red,
  );

  static const _colorScheme = ColorScheme(
    primary: _primary4,
    primaryVariant: _primary5,
    secondary: _secondary1,
    secondaryVariant: _secondary2,
    background: _light,
    surface: _light,
    onBackground: _black,
    onSurface: _black,
    error: _error,
    onError: _white,
    onPrimary: _white,
    onSecondary: _white,
    brightness: Brightness.light,
  );

  static final TextTheme _textTheme = TextTheme(
    headline1: _headline1,
    headline2: _headline2,
    headline3: _headline3,
    headline4: _headline4,
    headline5: _headline5,
    headline6: _headline6,
    subtitle1: _mediumBold.copyWith(color: _darkGrey),
    subtitle2: _medium.copyWith(color: _darkGrey),
    bodyText1: _medium,
    bodyText2: _small,
    button: _mediumBold,
    caption: _extraSmall,
    // STYLES NOT DEFINED
    overline: _fallback,
  );

  static final themeData = ThemeData(
    colorScheme: _colorScheme,
    appBarTheme: AppBarTheme(
      color: _colorScheme.primary,
      iconTheme: IconThemeData(color: _colorScheme.onPrimary),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: _colorScheme.primary,
    ),
    canvasColor: _colorScheme.background,
    toggleableActiveColor: _colorScheme.primary,
    highlightColor: Colors.transparent,
    indicatorColor: _colorScheme.primary,
    primaryColor: _colorScheme.primary,
    backgroundColor: _white,
    scaffoldBackgroundColor: _colorScheme.background,
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
    typography: Typography.material2018(
      platform: defaultTargetPlatform,
    ),
    textTheme: _textTheme.apply(
      bodyColor: _black,
      displayColor: _black,
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
      unselectedLabelColor: _darkGrey,
      labelStyle: _medium,
      unselectedLabelStyle: _medium,
    ),
    dividerColor: _lightGrey,
  );
}

extension CustomColorScheme on ColorScheme {
  Color get primary1 => FigurePayThemeData._primary1;
  Color get primary2 => FigurePayThemeData._primary2;
  Color get primary3 => FigurePayThemeData._primary3;
  Color get primary4 => FigurePayThemeData._primary4;
  Color get primary5 => FigurePayThemeData._primary5;
  Color get primary6 => FigurePayThemeData._primary6;
  Color get primary7 => FigurePayThemeData._primary7;
  Color get primaryP500 => FigurePayThemeData._primary550;
  Color get white => FigurePayThemeData._white;
  Color get light => FigurePayThemeData._light;
  Color get lightGrey => FigurePayThemeData._lightGrey;
  Color get midGrey => FigurePayThemeData._midGrey;
  Color get grey => FigurePayThemeData._grey;
  Color get black => FigurePayThemeData._black;
  Color get positive => FigurePayThemeData._positive;
  Color get warning => FigurePayThemeData._warning;
  Color get error => FigurePayThemeData._error;
  Color get darkGrey => FigurePayThemeData._darkGrey;
  Color get lime => FigurePayThemeData._lime;
  Color get systemGreen => FigurePayThemeData._systemGreen;
  Color get pickerGrey => FigurePayThemeData._pickerGrey;
  Color get pickerBlack => FigurePayThemeData._pickerBlack;
  Color get globalNeutral50 => FigurePayThemeData._globalNeutral50;
  Color get globalNeutral150 => FigurePayThemeData._globalNeutral150;
  Color get globalNeutral550 => FigurePayThemeData._globalNeutral550;
  Color get globalNeutral500 => FigurePayThemeData._globalNeutral500;
  Color get globalNeutral600Black => FigurePayThemeData._globalNeutral600Black;
  Color get globalNeutral400 => FigurePayThemeData._globalNeutral400;
  Color get globalNeutral450 => FigurePayThemeData._globalNeutral450;
  Color get globalNeutral350 => FigurePayThemeData._globalNeutral350;
  Color get globalNeutral250 => FigurePayThemeData._globalNeutral250;
  Color get otherBackground => FigurePayThemeData._otherBackground;
}

extension CustomTextTheme on TextTheme {
  TextStyle get headline0 => FigurePayThemeData._headline0;
  TextStyle get mediumBold => FigurePayThemeData._mediumBold;
  TextStyle get medium => FigurePayThemeData._medium;
  TextStyle get mediumSemiBold => FigurePayThemeData._mediumSemiBold;
  TextStyle get smallBold => FigurePayThemeData._smallBold;
  TextStyle get smallSemiBold => FigurePayThemeData._smallSemiBold;
  TextStyle get small => FigurePayThemeData._small;
  TextStyle get extraSmallBold => FigurePayThemeData._extraSmallBold;
  TextStyle get extraSmall => FigurePayThemeData._extraSmall;
  TextStyle get headline7 => FigurePayThemeData._headline7;
  TextStyle get extraLarge => FigurePayThemeData._extraLarge;
}
