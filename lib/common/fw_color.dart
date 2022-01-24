import 'package:flutter_tech_wallet/common/fw_design.dart';

/// Figma Typopgraphy Text Styles
enum FwColor {
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
  globalNeutral550,
  globalNeutral600Black,
  globalNeutral450,
  globalNeutral400,
  globalNeutral350,
  globalNeutral500,
}

mixin FwColorMixin on Widget {
  FwColor? get color;

  Color? getColor(
    BuildContext context, {
    FwColor? altColor,
  }) {
    final theme = Theme.of(context);

    switch (altColor ?? color) {
      case FwColor.white:
        return theme.colorScheme.white;
      case FwColor.light:
        return theme.colorScheme.light;
      case FwColor.lightGrey:
        return theme.colorScheme.lightGrey;
      case FwColor.midGrey:
        return theme.colorScheme.midGrey;
      case FwColor.grey:
        return theme.colorScheme.grey;
      case FwColor.darkGrey:
        return theme.colorScheme.darkGrey;
      case FwColor.black:
        return theme.colorScheme.black;
      case FwColor.positive:
        return theme.colorScheme.positive;
      case FwColor.error:
        return theme.colorScheme.error;
      case FwColor.warning:
        return theme.colorScheme.warning;
      case FwColor.primary1:
        return theme.colorScheme.primary1;
      case FwColor.primary2:
        return theme.colorScheme.primary2;
      case FwColor.primary3:
        return theme.colorScheme.primary3;
      case FwColor.primary4:
        return theme.colorScheme.primary4;
      case FwColor.primary5:
        return theme.colorScheme.primary5;
      case FwColor.primary6:
        return theme.colorScheme.primary6;
      case FwColor.secondary1:
        return theme.colorScheme.secondary;
      case FwColor.secondary2:
        return theme.colorScheme.secondaryVariant;
      case FwColor.lime:
        return theme.colorScheme.lime;
      case FwColor.globalNeutral350:
        return theme.colorScheme.globalNeutral350;
      case FwColor.globalNeutral400:
        return theme.colorScheme.globalNeutral400;
      case FwColor.globalNeutral450:
        return theme.colorScheme.globalNeutral450;
      case FwColor.globalNeutral550:
        return theme.colorScheme.globalNeutral550;
      case FwColor.globalNeutral600Black:
        return theme.colorScheme.globalNeutral600Black;
      case FwColor.globalNeutral500:
        return theme.colorScheme.globalNeutral500;
      default:
        return null;
    }
  }
}
