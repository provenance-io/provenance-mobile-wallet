import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/no_transactions_placeholder.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/transactions_list.dart';

class TransactionLanding extends StatefulWidget {
  const TransactionLanding({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TransactionLandingState();
}

class TransactionLandingState extends State<TransactionLanding> {
  List<Transaction> _transactions = [];

  void updateTransactions(List<Transaction> transactions) {
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
          : TransactionsList(),
    );
  }
}
