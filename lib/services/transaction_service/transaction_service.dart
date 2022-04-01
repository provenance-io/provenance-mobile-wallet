import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class TransactionService {
  Future<List<Transaction>> getTransactions(
    Coin coin,
    String provenanceAddress,
  ) {
    throw throw Strings.notImplementedMessage;
  }
}
