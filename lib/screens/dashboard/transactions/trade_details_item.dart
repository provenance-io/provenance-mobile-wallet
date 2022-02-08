import 'package:provenance_wallet/common/pw_design.dart';

class TradeDetailsItem extends StatelessWidget {
  TradeDetailsItem({required this.title, required this.endChild});
  TradeDetailsItem.fromStrings({required this.title, required String value}) {
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
