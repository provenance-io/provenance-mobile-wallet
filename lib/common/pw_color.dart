import 'package:provenance_wallet/common/pw_design.dart';

/// Figma Typopgraphy Text Styles
enum PwColor {
  error,
  secondary2,
  neutral700,
  neutral550,
  neutral450,
  neutral250,
  neutral200,
  neutral50,
  neutralNeutral,
  notice800,
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
      case PwColor.error:
        return theme.colorScheme.error;
      case PwColor.secondary2:
        return theme.colorScheme.secondaryVariant;
      case PwColor.neutral700:
        return theme.colorScheme.neutral700;
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
      case PwColor.notice800:
        return theme.colorScheme.notice800;
      case PwColor.primaryP500:
        return theme.colorScheme.primary500;
      default:
        return null;
    }
  }
}
