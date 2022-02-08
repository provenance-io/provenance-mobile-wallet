import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/network/models/transaction_response.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/no_transactions_placeholder.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/transactions_list.dart';

class TransactionLanding extends StatefulWidget {
  TransactionLanding({
    Key? key,
    required this.walletAddress,
    required this.walletName,
  }) : super(key: key);

  // FIXME: I want these two Strings to be part of a Bloc.
  final String walletName;
  final String walletAddress;

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
          : TransactionsList(
              transactions: _transactions,
              walletAddress: widget.walletAddress,
              walletName: widget.walletName,
            ),
    );
  }
}
