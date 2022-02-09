import 'package:provenance_wallet/common/pw_design.dart';

/// Figma Typopgraphy Text Styles
enum PwColor {
  // greys
  white,
  light,
  lightGrey,
  midGrey,
  grey,
  darkGrey,
  black,
  // functional
  positive,
  error,
  warning,
  // primary
  primary1,
  primary2,
  primary3,
  primary4,
  primary5,
  primary6,
  // secondary
  secondary1,
  secondary2,
  // accent
  lime,
  // new
  globalNeutral150,
  globalNeutral550,
  globalNeutral600Black,
  globalNeutral450,
  globalNeutral400,
  globalNeutral350,
  globalNeutral500,
}

mixin PwColorMixin on Widget {
  PwColor? get color;

  Color? getColor(
    BuildContext context, {
    PwColor? altColor,
  }) {
    final theme = Theme.of(context);

    switch (altColor ?? color) {
      case PwColor.white:
        return theme.colorScheme.white;
      case PwColor.light:
        return theme.colorScheme.light;
      case PwColor.lightGrey:
        return theme.colorScheme.lightGrey;
      case PwColor.midGrey:
        return theme.colorScheme.midGrey;
      case PwColor.grey:
        return theme.colorScheme.grey;
      case PwColor.darkGrey:
        return theme.colorScheme.darkGrey;
      case PwColor.black:
        return theme.colorScheme.black;
      case PwColor.positive:
        return theme.colorScheme.positive;
      case PwColor.error:
        return theme.colorScheme.error;
      case PwColor.warning:
        return theme.colorScheme.warning;
      case PwColor.primary1:
        return theme.colorScheme.primary1;
      case PwColor.primary2:
        return theme.colorScheme.primary2;
      case PwColor.primary3:
        return theme.colorScheme.primary3;
      case PwColor.primary4:
        return theme.colorScheme.primary4;
      case PwColor.primary5:
        return theme.colorScheme.primary5;
      case PwColor.primary6:
        return theme.colorScheme.primary6;
      case PwColor.secondary1:
        return theme.colorScheme.secondary;
      case PwColor.secondary2:
        return theme.colorScheme.secondaryVariant;
      case PwColor.lime:
        return theme.colorScheme.lime;
      case PwColor.globalNeutral150:
        return theme.colorScheme.globalNeutral150;
      case PwColor.globalNeutral350:
        return theme.colorScheme.globalNeutral350;
      case PwColor.globalNeutral400:
        return theme.colorScheme.globalNeutral400;
      case PwColor.globalNeutral450:
        return theme.colorScheme.globalNeutral450;
      case PwColor.globalNeutral550:
        return theme.colorScheme.globalNeutral550;
      case PwColor.globalNeutral600Black:
        return theme.colorScheme.globalNeutral600Black;
      case PwColor.globalNeutral500:
        return theme.colorScheme.globalNeutral500;
      default:
        return null;
    }
  }
}
