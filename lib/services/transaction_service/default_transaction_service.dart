import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/services/transaction_service/dtos/transaction_dto.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/util/get.dart';

class DefaultTransactionService extends TransactionService {
  String get _transactionServiceBasePath =>
      '/service-mobile-wallet/external/api/v1/address';

  @override
  Future<List<Transaction>> getTransactions(
    String provenanceAddress,
  ) async {
    final data = await get<HttpClient>().get(
      '$_transactionServiceBasePath/$provenanceAddress/transactions',
      listConverter: (json) {
        if (json is String) {
          return <Transaction>[];
        }

        final List<Transaction> transactions = [];

        transactions.addAll(json.map((t) {
          return Transaction(dto: TransactionDto.fromJson(t));
        }).toList());

        return transactions;
      },
    );

    return data.data ?? [];
  }
}
