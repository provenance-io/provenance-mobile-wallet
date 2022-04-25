// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:provenance_blockchain_wallet/common/pw_design.dart';

class DetailsItem extends StatelessWidget {
  DetailsItem({
    Key? key,
    this.padding,
    required this.title,
    required this.endChild,
  }) : super(key: key);

  DetailsItem.fromStrings({
    Key? key,
    this.padding,
    required this.title,
    required String value,
  }) : super(key: key) {
    endChild = PwText(
      value,
      style: PwTextStyle.body,
    );
  }

  final String title;
  late final Widget endChild;
  final EdgeInsets? padding;

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
            style: PwTextStyle.body,
          ),
          Expanded(child: Container()),
          endChild,
        ],
      ),
    );
  }
}
