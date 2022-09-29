import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/asset/dashboard_tab_bloc.dart';
import 'package:provenance_wallet/screens/home/dashboard/transactions_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/transaction_list_item.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class ViewAllTransactionsScreen extends StatelessWidget {
  const ViewAllTransactionsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<TransactionsBloc>(context);

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
              Strings.of(context).allTransactions,
              style: PwTextStyle.footnote,
            ),
            leading: IconButton(
              icon: PwIcon(
                PwIcons.back,
              ),
              onPressed: () {
                Provider.of<DashboardTabBloc>(context, listen: false)
                    .closeViewAllTransactions();
              },
            ),
          ),
          body: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.large,
            ),
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
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
