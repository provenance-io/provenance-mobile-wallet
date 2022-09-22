import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provenance_wallet/common/widgets/pw_spacer.dart';
import 'package:provenance_wallet/common/widgets/pw_thumb_shape.dart';

class ProvenanceColorScheme extends ColorScheme {
  const ProvenanceColorScheme({
    Brightness brightness = Brightness.light,
    required Color primary,
    required Color onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    required Color secondary,
    required Color onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    required Color error,
    required Color onError,
    Color? errorContainer,
    Color? onErrorContainer,
    required Color background,
    required Color onBackground,
    required Color surface,
    required Color onSurface,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? outline,
    Color? shadow,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? inversePrimary,
    Color? surfaceTint,
    this.graphNegative,
    this.graphNeutral,
    this.graphPositive,
    this.graphFill,
    required this.graphLine,
    required this.actionListSelectedColor,
    required this.actionNotListSelectedColor,
    required this.actionListCellBackground,
  }) : super(
          brightness: brightness,
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          secondary: secondary,
          onSecondary: onSecondary,
          secondaryContainer: secondaryContainer,
          onSecondaryContainer: onSecondaryContainer,
          tertiary: tertiary,
          onTertiary: onTertiary,
          tertiaryContainer: tertiaryContainer,
          onTertiaryContainer: onTertiaryContainer,
          error: error,
          onError: onError,
          errorContainer: errorContainer,
          onErrorContainer: onErrorContainer,
          background: background,
          onBackground: onBackground,
          surface: surface,
          onSurface: onSurface,
          surfaceVariant: surfaceVariant,
          onSurfaceVariant: onSurfaceVariant,
          outline: outline,
          shadow: shadow,
          inverseSurface: inverseSurface,
          onInverseSurface: onInverseSurface,
          inversePrimary: inversePrimary,
          surfaceTint: surfaceTint,
        );

  final Color? graphNegative;
  final Color? graphNeutral;
  final Color? graphPositive;
  final Color graphLine;
  final Color? graphFill;
  final Color actionListSelectedColor;
  final Color actionNotListSelectedColor;
  final Color actionListCellBackground;

  @override
  ProvenanceColorScheme copyWith(
      {Brightness? brightness,
      Color? primary,
      Color? onPrimary,
      Color? primaryContainer,
      Color? onPrimaryContainer,
      Color? secondary,
      Color? onSecondary,
      Color? secondaryContainer,
      Color? onSecondaryContainer,
      Color? tertiary,
      Color? onTertiary,
      Color? tertiaryContainer,
      Color? onTertiaryContainer,
      Color? error,
      Color? onError,
      Color? errorContainer,
      Color? onErrorContainer,
      Color? background,
      Color? onBackground,
      Color? surface,
      Color? onSurface,
      Color? surfaceVariant,
      Color? onSurfaceVariant,
      Color? outline,
      Color? shadow,
      Color? inverseSurface,
      Color? onInverseSurface,
      Color? inversePrimary,
      Color? surfaceTint,
      Color? primaryVariant,
      Color? secondaryVariant,
      Color? graphNegative,
      Color? graphNeutral,
      Color? graphPositive,
      Color? graphFill,
      Color? graphLine,
      Color? actionListSelectedColor,
      Color? actionNotListSelectedColor,
      Color? actionListCellBackground}) {
    return ProvenanceColorScheme(
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      shadow: shadow ?? this.shadow,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      graphNegative: graphNegative ?? this.graphNegative,
      graphNeutral: graphNeutral ?? this.graphNeutral,
      graphPositive: graphPositive ?? this.graphPositive,
      graphLine: graphLine ?? this.graphLine,
      graphFill: graphFill ?? this.graphFill,
      actionListSelectedColor:
          actionListSelectedColor ?? this.actionListSelectedColor,
      actionNotListSelectedColor:
          actionNotListSelectedColor ?? this.actionNotListSelectedColor,
      actionListCellBackground:
          actionListCellBackground ?? this.actionListCellBackground,
    );
  }
}

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
  static const Color _neutral150 = Color(0xFFD0D3DC);
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
  static const Color _secondary700 = Color(0xFF013C3B);
  static const Color _secondary650 = Color(0xFF01504F);
  static const Color _secondary400 = Color(0xFF03B5B2);
  static const Color _secondary350 = Color(0xFF03DAD5);
  static const Color _secondary300 = Color(0xFF04F1ED);
  static const Color _secondary250 = Color(0xFF22FCF8);

  // Other
  static const Color _provenanceLogo = Color(0xFF3F80F3);
  static const Color _error = Color(0xFFED6E74);
  static const Color _negative350 = Color(0xFFE01B25);
  static const Color _notice350 = Color(0xFFF4B601);
  static const Color _notice800 = Color(0xFF140F00);
  static const Color _positive300 = Color(0xFF5AE70D);
  static const Color _depositPeriod = Color(0xFFFEC10B);
  static const Color _votingPeriod = Color(0xFFA898EA);
  static const Color _vetoed = Color(0xFFB0B5CA);

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
    letterSpacing: 14 * 0.04,
    height: 22.4 / 14,
  );
  static const TextStyle _bodySmall = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 12 * 0.04,
    height: 19.2 / 12,
  );
  static const TextStyle _bodyXSmallBold = TextStyle(
    fontFamily: 'GothicA1',
    fontSize: 10.24,
    fontWeight: FontWeight.w700,
    height: 16 / 10.24,
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
  );

  static const _colorScheme = ProvenanceColorScheme(
      primary: _primary500,
      primaryContainer: _primary550,
      secondary: _secondary400,
      secondaryContainer: _secondary400,
      background: _neutral750,
      surface: _neutral50,
      onBackground: _neutralNeutral,
      onSurface: _neutralNeutral,
      error: _error,
      onError: _neutralNeutral,
      onPrimary: _neutralNeutral,
      onSecondary: _neutralNeutral,
      brightness: Brightness.light,
      graphNegative: Color.fromARGB(
        255,
        0xF1,
        0x6F,
        0x04,
      ),
      graphNeutral: Color.fromARGB(
        255,
        0xA6,
        0xA6,
        0xA6,
      ),
      graphPositive: Color.fromARGB(
        255,
        0x04,
        0xF1,
        0x9C,
      ),
      graphLine: Color.fromARGB(
        255,
        0x04,
        0xF1,
        0xED,
      ),
      graphFill: null,
      actionListSelectedColor: Color.fromARGB(255, 0x01, 0x3C, 0x3B),
      actionNotListSelectedColor: Color.fromARGB(255, 0x3E, 0x41, 0x51),
      actionListCellBackground: Color.fromARGB(255, 0x2B, 0x2F, 0x3A));

  static final TextTheme _textTheme = TextTheme(
    headline1: _headline1,
    headline2: _headline2,
    headline3: _headline3,
    headline4: _headline4,
    headline5: _display1,
    headline6: _display2,
    subtitle1: _title,
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
      color: _colorScheme.primary500,
      iconTheme: IconThemeData(color: _colorScheme.onPrimary),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: _colorScheme.primary,
    ),
    canvasColor: _colorScheme.background,
    toggleableActiveColor: _colorScheme.primary500,
    highlightColor: Colors.transparent,
    indicatorColor: _colorScheme.primary500,
    primaryColor: _colorScheme.primary500,
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
        borderSide: BorderSide(color: _colorScheme.neutral250),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
    ),
    unselectedWidgetColor: _colorScheme.neutral250,
    tabBarTheme: TabBarTheme(
      labelColor: _colorScheme.primary,
      unselectedLabelColor: _neutral550,
      labelStyle: _medium,
      unselectedLabelStyle: _medium,
    ),
    dividerColor: _neutral600,
  );
}

extension CustomSliderTheme on SliderThemeData {
  // unfortunately for some reason this theme gets overridden with the
  // default settings so we have to be weird about this.
  SliderThemeData get sliderThemeData => SliderThemeData(
      showValueIndicator: ShowValueIndicator.always,
      trackHeight: Spacing.xSmall,
      trackShape: RoundedRectSliderTrackShape(),
      activeTrackColor: ProvenanceThemeData._secondary350,
      inactiveTrackColor: ProvenanceThemeData._neutral700,
      overlayColor: ProvenanceThemeData._neutralNeutral,
      thumbShape: PwThumbShape(),
      thumbColor: ProvenanceThemeData._secondary350,
      overlayShape: RoundSliderOverlayShape(overlayRadius: 5.0),
      tickMarkShape: RoundSliderTickMarkShape(),
      activeTickMarkColor: Colors.transparent,
      inactiveTickMarkColor: Colors.transparent,
      valueIndicatorColor: ProvenanceThemeData._secondary350,
      valueIndicatorTextStyle: ProvenanceThemeData._textTheme.footnote
          .copyWith(color: ProvenanceThemeData._neutral800));
}

extension CustomColorScheme on ColorScheme {
  Color get neutral800 => ProvenanceThemeData._neutral800;
  Color get neutral750 => ProvenanceThemeData._neutral750;
  Color get neutral700 => ProvenanceThemeData._neutral700;
  Color get neutral600 => ProvenanceThemeData._neutral600;
  Color get neutral550 => ProvenanceThemeData._neutral550;
  Color get neutral500 => ProvenanceThemeData._neutral500;
  Color get neutral450 => ProvenanceThemeData._neutral450;
  Color get neutral250 => ProvenanceThemeData._neutral250;
  Color get neutral200 => ProvenanceThemeData._neutral200;
  Color get neutral150 => ProvenanceThemeData._neutral150;
  Color get neutral50 => ProvenanceThemeData._neutral50;
  Color get neutralNeutral => ProvenanceThemeData._neutralNeutral;

  Color get logo => ProvenanceThemeData._provenanceLogo;
  Color get primary700 => ProvenanceThemeData._primary700;
  Color get primary650 => ProvenanceThemeData._primary650;
  Color get primary550 => ProvenanceThemeData._primary550;
  Color get primary500 => ProvenanceThemeData._primary500;
  Color get primary400 => ProvenanceThemeData._primary400;

  Color get indicatorActive => ProvenanceThemeData._indicatorActive;
  Color get indicatorInActive => ProvenanceThemeData._indicatorInActive;
  Color get secondary700 => ProvenanceThemeData._secondary700;
  Color get secondary650 => ProvenanceThemeData._secondary650;
  Color get secondary400 => ProvenanceThemeData._secondary400;
  Color get secondary350 => ProvenanceThemeData._secondary350;
  Color get secondary300 => ProvenanceThemeData._secondary300;
  Color get secondary250 => ProvenanceThemeData._secondary250;
  Color get error => ProvenanceThemeData._error;
  Color get negative350 => ProvenanceThemeData._negative350;
  Color get notice350 => ProvenanceThemeData._notice350;
  Color get notice800 => ProvenanceThemeData._notice800;
  Color get positive300 => ProvenanceThemeData._positive300;
  Color get depositPeriod => ProvenanceThemeData._depositPeriod;
  Color get votingPeriod => ProvenanceThemeData._votingPeriod;
  Color get vetoed => ProvenanceThemeData._vetoed;
}

extension CustomTextTheme on TextTheme {
  TextStyle get medium => ProvenanceThemeData._medium;
  TextStyle get large =>
      ProvenanceThemeData._logo.copyWith(fontWeight: FontWeight.w600);
  TextStyle get logo => ProvenanceThemeData._logo;
  TextStyle get subhead => ProvenanceThemeData._subhead;
  TextStyle get body => ProvenanceThemeData._body;
  TextStyle get bodyBold => ProvenanceThemeData._bodyBold;
  TextStyle get bodySmall => ProvenanceThemeData._bodySmall;
  TextStyle get provenanceHeadline2 => ProvenanceThemeData._headline2;
  TextStyle get provenanceHeadline1 => ProvenanceThemeData._headline1;
  TextStyle get display1 => ProvenanceThemeData._display1;
  TextStyle get display2 => ProvenanceThemeData._display2;
  TextStyle get displayBody => ProvenanceThemeData._displayBody;
  TextStyle get footnote => ProvenanceThemeData._footnote;
  TextStyle get title => ProvenanceThemeData._title;
  TextStyle get extraSmallBold => ProvenanceThemeData._bodyXSmallBold;
}
