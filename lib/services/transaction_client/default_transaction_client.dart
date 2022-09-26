import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/models/send_transactions.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/notification/client_notification_mixin.dart';
import 'package:provenance_wallet/services/transaction_client/dtos/all_transactions_dto.dart';
import 'package:provenance_wallet/services/transaction_client/dtos/send_transaction_dto.dart';
import 'package:provenance_wallet/services/transaction_client/transaction_client.dart';

class DefaultTransactionClient extends TransactionClient
    with ClientNotificationMixin, ClientCoinMixin {
  String get _transactionServiceBasePath =>
      '/service-mobile-wallet/external/api/v1/address';

  @override
  Future<List<SendTransaction>> getSendTransactions(
    Coin coin,
    String provenanceAddress,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      '$_transactionServiceBasePath/$provenanceAddress/transactions',
      listConverter: (json) {
        if (json is String) {
          return <SendTransaction>[];
        }

        final List<SendTransaction> transactions = [];

        transactions.addAll(json.map((t) {
          return SendTransaction(dto: SendTransactionDto.fromJson(t));
        }).toList());

        transactions.sort(
          (trans1, trans2) => trans2.timestamp.compareTo(trans1.timestamp),
        );

        return transactions;
      },
    );

    notifyOnError(data);

    return data.data ?? [];
  }

  @override
  Future<List<Transaction>> getTransactions(
    Coin coin,
    String provenanceAddress,
    int pageNumber,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      '$_transactionServiceBasePath/$provenanceAddress/transactions/all?count=50&page=$pageNumber',
      converter: (json) {
        if (json is String) {
          return <Transaction>[];
        }

        final List<Transaction> transactions = [];

        var allTransactions = AllTransactionsDto.fromJson(json);
        var test = allTransactions.transactions?.map((t) {
          return Transaction(dto: t);
        }).toList();

        if (test == null) {
          return <Transaction>[];
        }

        transactions.addAll(test);

        transactions.sort(
          (trans1, trans2) => trans2.time.compareTo(trans1.time),
        );

        return transactions;
      },
    );

    notifyOnError(data);

    return data.data ?? [];
  }
}
