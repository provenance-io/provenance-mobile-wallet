import 'package:provenance_wallet/common/pw_design.dart';

/// Figma Typopgraphy Text Styles
enum PwColor {
  logo,
  error,
  secondary2,
  secondary250,
  secondary350,
  neutral750,
  neutral700,
  neutral600,
  neutral550,
  neutral450,
  neutral250,
  neutral200,
  neutral150,
  neutral50,
  neutralNeutral,
  notice350,
  notice800,
  primaryP500,
  negative,
  positive,
  positive2,
  neutral,
  graphLine,
  graphFill,
  transparent,
}

mixin PwColorMixin on Widget {
  PwColor? get color;

  Color? getColor(
    BuildContext context, {
    PwColor? altColor,
  }) {
    final theme = Theme.of(context);

    switch (altColor ?? color) {
      case PwColor.logo:
        return theme.colorScheme.logo;
      case PwColor.error:
        return theme.colorScheme.error;
      case PwColor.secondary2:
        return theme.colorScheme.secondaryContainer;
      case PwColor.secondary250:
        return theme.colorScheme.secondary250;
      case PwColor.secondary350:
        return theme.colorScheme.secondary350;
      case PwColor.neutral750:
        return theme.colorScheme.neutral750;
      case PwColor.neutral700:
        return theme.colorScheme.neutral700;
      case PwColor.neutral600:
        return theme.colorScheme.neutral600;
      case PwColor.neutral450:
        return theme.colorScheme.neutral450;
      case PwColor.neutral550:
        return theme.colorScheme.neutral550;
      case PwColor.neutral250:
        return theme.colorScheme.neutral250;
      case PwColor.neutral200:
        return theme.colorScheme.neutral200;
      case PwColor.neutral150:
        return theme.colorScheme.neutral150;
      case PwColor.neutral50:
        return theme.colorScheme.neutral50;
      case PwColor.neutralNeutral:
        return theme.colorScheme.neutralNeutral;
      case PwColor.notice350:
        return theme.colorScheme.notice350;
      case PwColor.notice800:
        return theme.colorScheme.notice800;
      case PwColor.primaryP500:
        return theme.colorScheme.primary500;
      case PwColor.negative:
        if (theme.colorScheme is ProvenanceColorScheme) {
          return (theme.colorScheme as ProvenanceColorScheme).graphNegative;
        }
        return null;
      case PwColor.positive:
        if (theme.colorScheme is ProvenanceColorScheme) {
          return (theme.colorScheme as ProvenanceColorScheme).graphPositive;
        }
        return null;
      case PwColor.positive2:
        // TODO: Put in theme.dart.
        return Color(0XFF28CEA8);
      case PwColor.neutral:
        if (theme.colorScheme is ProvenanceColorScheme) {
          return (theme.colorScheme as ProvenanceColorScheme).graphNeutral;
        }
        return null;
      case PwColor.graphFill:
        if (theme.colorScheme is ProvenanceColorScheme) {
          return (theme.colorScheme as ProvenanceColorScheme).graphFill;
        }
        return null;
      case PwColor.graphLine:
        if (theme.colorScheme is ProvenanceColorScheme) {
          return (theme.colorScheme as ProvenanceColorScheme).graphLine;
        }
        return null;
      case PwColor.transparent:
        return Colors.transparent;
      default:
        return null;
    }
  }
}
