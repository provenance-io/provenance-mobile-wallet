import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/transaction_list_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class AssetChartRecentTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = get<DashboardBloc>();

    return Column(
      children: [
        VerticalSpacer.medium(),
        Row(
          children: const [
            PwText(
              Strings.recentTransactions,
              style: PwTextStyle.headline4,
            ),
          ],
        ),
        VerticalSpacer.medium(),
        PwListDivider(),
        StreamBuilder<TransactionDetails>(
          initialData: bloc.transactionDetails.value,
          stream: bloc.transactionDetails,
          builder: (context, snapshot) {
            final transactionDetails = snapshot.data;
            if (transactionDetails == null) {
              return Container();
            }
            final transactions =
                transactionDetails.transactions.take(4).toList();

            return Column(
              children: [
                ...transactions
                    .map((e) {
                      return [
                        TransactionListItem(
                          walletAddress: transactionDetails.walletAddress,
                          item: e,
                        ),
                        PwListDivider(),
                      ];
                    })
                    .expand((i) => i)
                    .toList(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    //TODO: Navigate to transactions
                  },
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PwText(
                            Strings.viewAllLabel,
                            style: PwTextStyle.bodyBold,
                          ),
                          Expanded(child: Container()),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: PwIcon(
                              PwIcons.caret,
                              color:
                                  Theme.of(context).colorScheme.neutralNeutral,
                              size: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                VerticalSpacer.largeX5(),
              ],
            );
          },
        ),
      ],
    );
  }
}
