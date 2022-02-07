import 'package:provenance_wallet/common/fw_design.dart';

class TradeDetailsItem extends StatelessWidget {
  TradeDetailsItem({required this.title, required this.endChild});
  TradeDetailsItem.fromStrings({required this.title, required String value}) {
    endChild = FwText(
      value,
      color: FwColor.globalNeutral500,
      style: FwTextStyle.m,
    );
  }
  final String title;
  late final Widget endChild;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FwText(
          title,
          color: FwColor.globalNeutral350,
          style: FwTextStyle.m,
        ),
        Expanded(child: Container()),
        endChild,
      ],
    );
  }
}
