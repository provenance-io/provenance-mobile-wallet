import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/trade_details_screen.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class TransactionLandingTab extends StatefulWidget {
  const TransactionLandingTab({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TransactionLandingTabState();
}

class TransactionLandingTabState extends State<TransactionLandingTab> {
  @override
  Widget build(BuildContext context) {
    final bloc = get<DashboardBloc>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.provenanceNeutral750,
        elevation: 0.0,
        title: PwText(
          Strings.transactionDetails,
          style: PwTextStyle.subhead,
        ),
        leading: Container(),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.provenanceNeutral750,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.xxLarge,
              ),
              child: Column(
                children: [
                  // FIXME: get the right items for these.

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Theme.of(context).colorScheme.provenanceNeutral250,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.medium,
                    ),
                    child: PwDropDown.fromStrings(
                      initialValue: Strings.dropDownAllAssets,
                      items: [
                        Strings.dropDownAllAssets,
                        Strings.dropDownHashAsset,
                        Strings.dropDownUsdAsset,
                        Strings.dropDownUsdfAsset,
                      ],
                    ),
                  ),
                  VerticalSpacer.medium(),
                  // FIXME: get the right items for these.
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Theme.of(context).colorScheme.provenanceNeutral250,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.medium,
                    ),
                    child: PwDropDown.fromStrings(
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
            StreamBuilder<List<Transaction>>(
              initialData: bloc.transactionList.value,
              stream: bloc.transactionList,
              builder: (context, snapshot) {
                final transactions = snapshot.data ?? [];

                return Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    itemBuilder: (context, index) {
                      final item = transactions[index];

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          // TODO: Finding a "tappable" area is difficult and janky. Fix me.
                          Navigator.of(context).push(TradeDetailsScreen(
                            transaction: item,
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .globalNeutral550,
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .globalNeutral550,
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
                    itemCount: transactions.length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                  ),
                );
              },
            ),
            VerticalSpacer.large(),
          ],
        ),
      ),
    );
  }
}
