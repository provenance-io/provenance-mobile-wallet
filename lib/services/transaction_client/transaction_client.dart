import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/send_transactions.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class TransactionClient {
  Future<List<SendTransaction>> getSendTransactions(
    Coin coin,
    String provenanceAddress,
  ) {
    throw throw Strings.notImplementedMessage;
  }

  Future<List<Transaction>> getTransactions(
    Coin coin,
    String provenanceAddress,
    int pageNumber,
  ) {
    throw throw Strings.notImplementedMessage;
  }
}
