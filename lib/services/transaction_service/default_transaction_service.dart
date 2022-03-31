import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/notification/client_notification_mixin.dart';
import 'package:provenance_wallet/services/transaction_service/dtos/transaction_dto.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';

class DefaultTransactionService extends TransactionService
    with ClientNotificationMixin, ClientCoinMixin {
  String get _transactionServiceBasePath =>
      '/service-mobile-wallet/external/api/v1/address';

  @override
  Future<List<Transaction>> getTransactions(
    Coin coin,
    String provenanceAddress,
  ) async {
    final client = getClient(coin);
    final data = await client.get(
      '$_transactionServiceBasePath/$provenanceAddress/transactions',
      listConverter: (json) {
        if (json is String) {
          return <Transaction>[];
        }

        final List<Transaction> transactions = [];

        transactions.addAll(json.map((t) {
          return Transaction(dto: TransactionDto.fromJson(t));
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
}
