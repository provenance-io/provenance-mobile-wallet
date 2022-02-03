import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/fw_dropdown.dart';
import 'package:provenance_wallet/network/models/transaction_response.dart';

class TransactionsList extends StatefulWidget {
  TransactionsList({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  final List<TransactionResponse> transactions;
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
                child: FwDropDown(
                  initialValue: "All Assets",
                  items: [
                    "All Assets",
                    "Hash",
                    "USDF",
                  ],
                ),
              ),
              HorizontalSpacer.medium(),
              // FIXME: get the right items for these.
              Container(
                padding: EdgeInsets.only(right: 10, left: 10),
                color: Theme.of(context).colorScheme.globalNeutral150,
                child: FwDropDown(
                  initialValue: "All Transactions",
                  items: [
                    "All Transactions",
                    "Purchase",
                    "Deposit",
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
                onTap: () {
                  // TODO: go to transaction/trade details.
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
                          child: FwIcon(
                            FwIcons.hashLogo,
                            color:
                                Theme.of(context).colorScheme.globalNeutral550,
                            size: 32,
                          ),
                        ),
                        HorizontalSpacer.medium(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FwText(
                              // FIXME: Transactions have no 'display' property atm.
                              'HASH',
                              color: FwColor.globalNeutral500,
                              style: FwTextStyle.sBold,
                            ),
                            VerticalSpacer.xSmall(),
                            FwText(
                              item.type ?? '',
                              color: FwColor.globalNeutral450,
                              style: FwTextStyle.s,
                            ),
                          ],
                        ),
                        Expanded(child: Container()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FwText(
                              // FIXME: Transactions currently only have 'feeAmount'.
                              '\$50.00',
                              color: FwColor.globalNeutral500,
                              style: FwTextStyle.sBold,
                            ),
                            VerticalSpacer.xSmall(),
                            FwText(
                              // FIXME: Format the date to be 'Mmm dd'.
                              item.time ?? '',
                              color: FwColor.globalNeutral450,
                              style: FwTextStyle.s,
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: FwIcon(
                            FwIcons.caret,
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
              return Divider(
                height: 1,
                thickness: 1,
                indent: 0,
                endIndent: 0,
                color: Theme.of(context).dividerColor,
              );
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
