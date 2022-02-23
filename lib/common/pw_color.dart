import 'package:provenance_wallet/common/pw_design.dart';

/// Figma Typopgraphy Text Styles
enum PwColor {
  light,
  lightGrey,
  midGrey,
  darkGrey,
  black,
  positive,
  error,
  primary4,
  secondary1,
  secondary2,
  neutral550,
  neutral450,
  neutral250,
  neutral200,
  neutral50,
  neutralNeutral,
  primaryP500,
}

mixin PwColorMixin on Widget {
  PwColor? get color;

  Color? getColor(
    BuildContext context, {
    PwColor? altColor,
  }) {
    final theme = Theme.of(context);

    switch (altColor ?? color) {
      case PwColor.light:
        return theme.colorScheme.light;
      case PwColor.lightGrey:
        return theme.colorScheme.lightGrey;
      case PwColor.midGrey:
        return theme.colorScheme.midGrey;
      case PwColor.darkGrey:
        return theme.colorScheme.darkGrey;
      case PwColor.black:
        return theme.colorScheme.black;
      case PwColor.positive:
        return theme.colorScheme.positive;
      case PwColor.error:
        return theme.colorScheme.error;
      case PwColor.primary4:
        return theme.colorScheme.primary400;
      case PwColor.secondary1:
        return theme.colorScheme.secondary;
      case PwColor.secondary2:
        return theme.colorScheme.secondaryVariant;
      case PwColor.neutral450:
        return theme.colorScheme.neutral450;
      case PwColor.neutral550:
        return theme.colorScheme.neutral550;
      case PwColor.neutral250:
        return theme.colorScheme.neutral250;
      case PwColor.neutral200:
        return theme.colorScheme.neutral200;
      case PwColor.neutral50:
        return theme.colorScheme.neutral50;
      case PwColor.neutralNeutral:
        return theme.colorScheme.neutralNeutral;
      case PwColor.primaryP500:
        return theme.colorScheme.primary500;
      default:
        return null;
    }
  }
}
