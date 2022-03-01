import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class TransactionService {
  Future<List<Transaction>> getTransactions(
    String provenanceAddress,
  ) {
    throw throw Strings.notImplementedMessage;
  }
}