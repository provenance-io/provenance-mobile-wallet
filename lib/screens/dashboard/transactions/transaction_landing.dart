import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/network/models/transaction_response.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/no_transactions_placeholder.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/transactions_list.dart';

class TransactionLanding extends StatefulWidget {
  TransactionLanding({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TransactionLandingState();
}

class TransactionLandingState extends State<TransactionLanding> {
  List<TransactionResponse> _transactions = [];

  void updateTransactions(List<TransactionResponse> transactions) {
    setState(() {
      _transactions = transactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.white,
      padding: EdgeInsets.only(top: 40),
      child: _transactions.isEmpty
          ? NoTransactionsPlaceholder()
          : TransactionsList(transactions: _transactions),
    );
  }
}
