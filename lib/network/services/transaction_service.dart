import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/network/dtos/transaction_dto.dart';
import 'package:provenance_wallet/network/services/base_service.dart';
import 'package:faker/faker.dart';

class TransactionService {
  String get _transactionServiceBasePath =>
      '/service-mobile-wallet/external/api/v1/address';

  Future<BaseResponse<List<Transaction>>> getTransactions(
    String provenanceAddress,
  ) async {
    final data = await BaseService.instance.GET(
      '$_transactionServiceBasePath/$provenanceAddress/transactions',
      listConverter: (json) {
        if (json is String) {
          return <Transaction>[];
        }

        final List<Transaction> transactions = [];

        try {
          transactions.addAll(json.map((t) {
            return Transaction(dto: TransactionDto.fromJson(t));
          }).toList());
        } catch (e) {
          return transactions;
        }

        return transactions;
      },
    );

    return data;
  }

  // TODO: Remove me when we can mock
  Future<List<Transaction>> getFakeTransactions(
    String provenanceAddresses,
  ) async {
    final faker = Faker();
    final List<Transaction> transactions = [];

    for (var i = 0; i < faker.randomGenerator.integer(10, min: 5); i++) {
      transactions.add(_getFakeTransaction());
    }

    await Future.delayed(
      Duration(
        milliseconds: faker.randomGenerator.integer(1000, min: 500),
      ),
    );

    return transactions;
  }

  // TODO: Remove me when we can mock
  Transaction _getFakeTransaction() {
    var faker = Faker();
    var amount = faker.randomGenerator.decimal().toStringAsFixed(2);

    return Transaction.fake(
      address: faker.randomGenerator
          .fromPatternToHex(['#########################################']),
      feeAmount: '$amount USD',
      id: faker.randomGenerator.integer(100000).toString(),
      signer: faker.person.name(),
      status: faker.randomGenerator.element([
        "Cancelled",
        "Completed",
      ]),
      time: faker.date.time(),
      type: faker.randomGenerator.element(
        [
          "Buy",
          "Purchase",
          "Deposit",
          "Withdraw",
        ],
      ),
    );
  }
}
