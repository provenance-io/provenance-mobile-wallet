import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/asset/dashboard_tab_bloc.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/transaction_list_item.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class AssetChartRecentTransactions extends StatelessWidget {
  const AssetChartRecentTransactions({Key? key, required this.asset})
      : super(key: key);

  final Asset asset;
  @override
  Widget build(BuildContext context) {
    final bloc = get<HomeBloc>();

    return Column(
      children: [
        VerticalSpacer.medium(),
        Row(
          children: [
            PwText(
              Strings.of(context).recentTransactions,
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
            final transactions = transactionDetails.transactions
                .where((element) => element.denom == asset.denom)
                .take(4)
                .toList();

            return Column(
              children: [
                ...transactions
                    .map((e) {
                      return [
                        TransactionListItem(
                          address: transactionDetails.address,
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
                    get<DashboardTabBloc>().openViewAllTransactions();
                  },
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PwText(
                            Strings.of(context).viewAllLabel,
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
