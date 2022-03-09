import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/transaction_list_item.dart';
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

    return Container(
      color: Theme.of(context).colorScheme.neutral750,
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<TransactionDetails>(
          initialData: bloc.transactionDetails.value,
          stream: bloc.transactionDetails,
          builder: (context, snapshot) {
            final transactionDetails = snapshot.data;
            if (transactionDetails == null) {
              return Container();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  primary: false,
                  backgroundColor: Theme.of(context).colorScheme.neutral750,
                  elevation: 0.0,
                  title: PwText(
                    Strings.transactionDetails,
                    style: PwTextStyle.subhead,
                  ),
                  leading: Container(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.xxLarge,
                  ),
                  child: Column(
                    children: [
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
                          initialValue: transactionDetails.selectedType,
                          items: transactionDetails.types,
                          onValueChanged: (item) {
                            bloc.filterTransactions(
                              item,
                              transactionDetails.selectedStatus,
                            );
                          },
                        ),
                      ),
                      VerticalSpacer.medium(),
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
                          items: transactionDetails.statuses,
                          onValueChanged: (item) {
                            bloc.filterTransactions(
                              transactionDetails.selectedType,
                              item,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalSpacer.medium(),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.xxLarge,
                      vertical: 20,
                    ),
                    itemBuilder: (context, index) {
                      final item =
                          transactionDetails.filteredTransactions[index];

                      return TransactionListItem(
                        walletAddress: transactionDetails.walletAddress,
                        item: item,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return PwListDivider();
                    },
                    itemCount: transactionDetails.filteredTransactions.length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
