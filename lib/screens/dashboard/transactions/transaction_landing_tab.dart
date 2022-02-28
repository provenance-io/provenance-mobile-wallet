import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/trade_details_screen.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class TransactionLandingTab extends StatelessWidget {
  const TransactionLandingTab({
    Key? key,
  }) : super(key: key);

  final textDivider = " • ";

  @override
  Widget build(BuildContext context) {
    final bloc = get<DashboardBloc>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.neutral750,
        elevation: 0.0,
        title: PwText(
          Strings.transactionDetails,
          style: PwTextStyle.subhead,
        ),
        leading: Container(),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
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
                        color: Theme.of(context).colorScheme.neutral250,
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
                        color: Theme.of(context).colorScheme.neutral250,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.xxLarge,
                      vertical: 20,
                    ),
                    itemBuilder: (context, index) {
                      final item = transactions[index];

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
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
                                SizedBox(
                                  width: Spacing.largeX3,
                                  height: Spacing.largeX3,
                                  // FIXME: Transactions have no 'display' property atm.
                                  child: PwIcon(
                                    PwIcons.hashLogo,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .neutralNeutral,
                                    size: Spacing.largeX3,
                                  ),
                                ),
                                HorizontalSpacer.medium(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PwText(
                                      // FIXME: Transactions have no 'display' property atm.
                                      Strings.dropDownHashAsset.toUpperCase(),
                                      style: PwTextStyle.bodyBold,
                                    ),
                                    VerticalSpacer.xSmall(),
                                    Row(
                                      children: [
                                        PwText(
                                          item.type,
                                          color: PwColor.neutral200,
                                          style: PwTextStyle.footnote,
                                        ),
                                        PwText(
                                          textDivider,
                                          color: PwColor.neutral200,
                                          style: PwTextStyle.footnote,
                                        ),
                                        PwText(
                                          // FIXME: Format the date to be 'Mmm dd'.
                                          item.time,
                                          color: PwColor.neutral200,
                                          style: PwTextStyle.footnote,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Expanded(child: Container()),
                                Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: PwIcon(
                                    PwIcons.caret,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .neutralNeutral,
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
          ],
        ),
      ),
    );
  }
}
