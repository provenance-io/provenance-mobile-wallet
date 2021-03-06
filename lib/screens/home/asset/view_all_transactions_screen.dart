import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/asset/dashboard_tab_bloc.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/transaction_list_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ViewAllTransactionsScreen extends StatelessWidget {
  const ViewAllTransactionsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = get<HomeBloc>();

    return StreamBuilder<TransactionDetails>(
      initialData: bloc.transactionDetails.value,
      stream: bloc.transactionDetails,
      builder: (context, snapshot) {
        final transactionDetails = snapshot.data;
        if (transactionDetails == null) {
          return Container();
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            flexibleSpace: Container(
              color: Colors.transparent,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            title: PwText(
              Strings.allTransactions,
              style: PwTextStyle.subhead,
            ),
            leading: Padding(
              padding: EdgeInsets.only(left: 21),
              child: IconButton(
                icon: PwIcon(
                  PwIcons.back,
                ),
                onPressed: () {
                  get<DashboardTabBloc>().closeViewAllTransactions();
                },
              ),
            ),
          ),
          body: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.xLarge,
            ),
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.xxLarge,
                      vertical: 20,
                    ),
                    itemBuilder: (context, index) {
                      final item = transactionDetails.transactions[index];

                      return TransactionListItem(
                        address: transactionDetails.address,
                        item: item,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return PwListDivider();
                    },
                    itemCount: transactionDetails.transactions.length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
