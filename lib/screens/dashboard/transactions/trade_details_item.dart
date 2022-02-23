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
      color: PwColor.globalNeutral500,
      style: PwTextStyle.m,
    );
  }

  final String title;
  late final Widget endChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PwText(
            title,
            color: PwColor.globalNeutral350,
            style: PwTextStyle.m,
          ),
          Expanded(child: Container()),
          endChild,
        ],
      ),
    );
  }
}
