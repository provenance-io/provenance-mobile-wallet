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

    return Transaction.fake(
      amount: faker.randomGenerator.integer(100000),
      block: faker.randomGenerator.integer(100000),
      denom: "USD",
      hash: faker.randomGenerator
          .fromPatternToHex(['#########################################']),
      recipientAddress: faker.randomGenerator
          .fromPatternToHex(['#########################################']),
      senderAddress: faker.randomGenerator
          .fromPatternToHex(['#########################################']),
      status: faker.randomGenerator.element([
        "Cancelled",
        "Completed",
      ]),
      timestamp: DateTime.now(),
      txFee: faker.randomGenerator.integer(100000),
    );
  }
}
