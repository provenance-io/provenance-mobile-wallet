import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/network/models/transaction_response.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/trade_details_item.dart';
import 'package:provenance_wallet/util/strings.dart';

class TradeDetailsScreen extends StatefulWidget {
  TradeDetailsScreen({
    Key? key,
    required this.transaction,
    required this.walletName,
  }) : super(key: key);

  final TransactionResponse transaction;
  final String walletName;

  @override
  State<StatefulWidget> createState() => TradeDetailsScreenState();
}

class TradeDetailsScreenState extends State<TradeDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 0.0,
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(
            top: 20,
          ),
          child: FwText(
            Strings.tradeDetailsTitle,
            style: FwTextStyle.h6,
            color: FwColor.globalNeutral550,
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(
            left: 24,
            top: 10,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: FwIcon(
              FwIcons.back,
              color: Theme.of(context).colorScheme.globalNeutral450,
              size: 24.0,
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TradeDetailsItem.fromStrings(
            title: "Wallet",
            value: widget.walletName,
          ),
          TradeDetailsItem(
            title: "Transaction #",
            endChild: Container(
              child: Row(
                children: [
                  FwText(
                    Strings.tradeDetailsTitle,
                    style: FwTextStyle.h6,
                    color: FwColor.globalNeutral600Black,
                  ),
                  FwIcon(
                    FwIcons.upArrow,
                    color: Theme.of(context).colorScheme.globalNeutral600Black,
                    size: 24.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
