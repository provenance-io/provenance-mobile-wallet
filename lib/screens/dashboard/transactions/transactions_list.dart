import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/trade_details_screen.dart';
import 'package:provenance_wallet/util/strings.dart';

class TransactionsList extends StatefulWidget {
  TransactionsList({
    Key? key,
    required this.transactions,
    required this.walletName,
    required this.walletAddress,
  }) : super(key: key);

  final List<Transaction> transactions;
  final String walletName;
  final String walletAddress;
  @override
  State<StatefulWidget> createState() => TransactionsListState();
}

class TransactionsListState extends State<TransactionsList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // FIXME: get the right items for these.
              Container(
                padding: EdgeInsets.only(right: 10, left: 10),
                color: Theme.of(context).colorScheme.globalNeutral150,
                child: PwDropDown(
                  initialValue: Strings.dropDownAllAssets,
                  items: [
                    Strings.dropDownAllAssets,
                    Strings.dropDownHashAsset,
                    Strings.dropDownUsdAsset,
                    Strings.dropDownUsdfAsset,
                  ],
                ),
              ),
              HorizontalSpacer.medium(),
              // FIXME: get the right items for these.
              Container(
                padding: EdgeInsets.only(right: 10, left: 10),
                color: Theme.of(context).colorScheme.globalNeutral150,
                child: PwDropDown(
                  initialValue: Strings.dropDownAllTransactions,
                  items: [
                    Strings.dropDownAllTransactions,
                    Strings.dropDownPurchaseTransaction,
                    Strings.dropDownDepositTransaction,
                  ],
                ),
              ),
            ],
          ),
        ),
        VerticalSpacer.medium(),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(left: 20, right: 20),
            itemBuilder: (context, index) {
              final item = widget.transactions[index];

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // TODO: Finding a "tappable" area is difficult and janky. Fix me.
                  Navigator.of(context).push(TradeDetailsScreen(
                    transaction: item,
                    walletName: widget.walletName,
                    walletAddress: widget.walletAddress,
                  ).route());
                },
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          // FIXME: Transactions have no 'display' property atm.
                          child: PwIcon(
                            PwIcons.hashLogo,
                            color:
                                Theme.of(context).colorScheme.globalNeutral550,
                            size: 32,
                          ),
                        ),
                        HorizontalSpacer.medium(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PwText(
                              // FIXME: Transactions have no 'display' property atm.
                              Strings.dropDownHashAsset.toUpperCase(),
                              color: PwColor.globalNeutral500,
                              style: PwTextStyle.sBold,
                            ),
                            VerticalSpacer.xSmall(),
                            PwText(
                              item.type,
                              color: PwColor.globalNeutral450,
                              style: PwTextStyle.s,
                            ),
                          ],
                        ),
                        Expanded(child: Container()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PwText(
                              // FIXME: Transactions currently only have 'feeAmount'.
                              '\$50.00',
                              color: PwColor.globalNeutral500,
                              style: PwTextStyle.sBold,
                            ),
                            VerticalSpacer.xSmall(),
                            PwText(
                              // FIXME: Format the date to be 'Mmm dd'.
                              item.time,
                              color: PwColor.globalNeutral450,
                              style: PwTextStyle.s,
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: PwIcon(
                            PwIcons.caret,
                            color:
                                Theme.of(context).colorScheme.globalNeutral550,
                            size: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return PwListDivider();
            },
            itemCount: widget.transactions.length,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
          ),
        ),
        VerticalSpacer.large(),
      ],
    );
  }
}
