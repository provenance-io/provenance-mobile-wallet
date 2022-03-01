import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:faker/faker.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';

class MockTransactionService extends TransactionService {
  @override
  Future<List<Transaction>> getTransactions(
    String provenanceAddress,
  ) async {
    final faker = Faker();
    final List<Transaction> transactions = [];

    for (var i = 0; i < faker.randomGenerator.integer(10, min: 5); i++) {
      transactions.add(_getTransaction());
    }

    await Future.delayed(
      Duration(
        milliseconds: faker.randomGenerator.integer(1000, min: 500),
      ),
    );

    return transactions;
  }

  Transaction _getTransaction() {
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
