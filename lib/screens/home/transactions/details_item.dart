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
