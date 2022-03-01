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
    var address1 = faker.randomGenerator
        .fromCharSet('1234567890abcdefghijklmnopqrstuvwzyz', 41);
    var address2 = faker.randomGenerator
        .fromCharSet('1234567890abcdefghijklmnopqrstuvwzyz', 41);

    return Transaction.fake(
      amount: faker.randomGenerator.integer(9999999999),
      block: faker.randomGenerator.integer(9999999),
      denom: faker.randomGenerator.element([
        "nhash",
        "cfigure",
      ]),
      hash: faker.randomGenerator.fromPatternToHex([
        '################################################################',
      ]).toUpperCase(),
      recipientAddress: address1,
      senderAddress: address2,
      status: "SUCCESS",
      timestamp: DateTime.now(),
      txFee: faker.randomGenerator.integer(999999999),
    );
  }
}
