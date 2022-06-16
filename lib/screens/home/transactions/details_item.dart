// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:provenance_wallet/common/pw_design.dart';

class DetailsItem extends StatelessWidget {
  DetailsItem({
    Key? key,
    this.padding,
    required this.title,
    required this.endChild,
    this.headerStyle = PwTextStyle.body,
    this.needsExpansion = true,
  }) : super(key: key);

  DetailsItem.fromStrings({
    Key? key,
    this.padding,
    required this.title,
    required String value,
    this.headerStyle = PwTextStyle.body,
    this.needsExpansion = true,
  }) : super(key: key) {
    endChild = PwText(
      value,
      style: PwTextStyle.body,
    );
  }

  final String title;
  late final Widget endChild;
  final EdgeInsets? padding;
  final PwTextStyle headerStyle;
  final bool needsExpansion;

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
            style: headerStyle,
          ),
          if (needsExpansion) Expanded(child: Container()),
          if (!needsExpansion) HorizontalSpacer.large(),
          endChild,
        ],
      ),
    );
  }
}
