// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:provenance_wallet/common/pw_design.dart';

class TradeDetailsItem extends StatelessWidget {
  TradeDetailsItem({
    Key? key,
    required this.title,
    required this.endChild,
  }) : super(key: key);

  TradeDetailsItem.fromStrings({
    Key? key,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.largeX3,
        vertical: Spacing.xLarge,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
