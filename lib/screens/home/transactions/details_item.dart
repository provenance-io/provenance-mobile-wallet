// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:provenance_wallet/common/pw_design.dart';

class DetailsItem extends StatelessWidget {
  DetailsItem({
    Key? key,
    this.padding,
    required this.title,
    required this.endChild,
    this.color,
    this.style = PwTextStyle.body,
  }) : super(key: key);

  DetailsItem.fromStrings({
    Key? key,
    this.padding,
    required this.title,
    required String value,
    this.color,
    this.style = PwTextStyle.body,
  }) : super(key: key) {
    endChild = PwText(
      value,
      style: style,
    );
  }

  DetailsItem.alternateStrings({
    Key? key,
    this.padding = const EdgeInsets.symmetric(vertical: Spacing.large),
    required this.title,
    required String value,
    this.color = PwColor.neutral200,
    this.style = PwTextStyle.footnote,
  }) : super(key: key) {
    endChild = PwText(
      value,
      style: style,
    );
  }

  DetailsItem.withRowChildren({
    Key? key,
    this.padding = const EdgeInsets.symmetric(vertical: Spacing.large),
    required this.title,
    required List<Widget> children,
    this.color = PwColor.neutral200,
    this.style = PwTextStyle.footnote,
  }) : super(key: key) {
    endChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  DetailsItem.withHash({
    Key? key,
    this.padding = const EdgeInsets.symmetric(vertical: Spacing.large),
    required this.title,
    required String hashString,
    required BuildContext context,
    this.color = PwColor.neutral200,
    this.style = PwTextStyle.footnote,
  }) : super(key: key) {
    endChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PwIcon(
          PwIcons.hashLogo,
          size: 24,
          color: Theme.of(context).colorScheme.neutralNeutral,
        ),
        HorizontalSpacer.small(),
        PwText(
          hashString,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: PwTextStyle.footnote,
        ),
      ],
    );
  }

  final String title;
  late final Widget endChild;
  final EdgeInsets? padding;
  final PwColor? color;

  final PwTextStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: Spacing.largeX3,
            vertical: Spacing.xLarge,
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PwText(
            title,
            style: style,
            color: color,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: endChild,
            ),
          ),
        ],
      ),
    );
  }
}
