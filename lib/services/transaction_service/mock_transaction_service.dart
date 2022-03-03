import 'package:faker/faker.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';

class MockTransactionService extends TransactionService {
  final faker = Faker();
  @override
  Future<List<Transaction>> getTransactions(
    String provenanceAddress,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));
    List<Transaction> transactions = [];

    final length = faker.randomGenerator.integer(10, min: 5);

    for (var i = 0; i < length; i++) {
      transactions.add(_getTransaction());
    }

    return transactions;
  }

  Transaction _getTransaction() {
    var amount = faker.randomGenerator.integer(999999999);
    var address1 = faker.randomGenerator
        .fromCharSet('1234567890abcdefghijklmnopqrstuvwzyz', 41);
    var address2 = faker.randomGenerator
        .fromCharSet('1234567890abcdefghijklmnopqrstuvwzyz', 41);
    var pricePerUnit = faker.randomGenerator.decimal();

    return Transaction.fake(
      amount: amount,
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
      pricePerUnit: pricePerUnit,
      totalPrice: pricePerUnit * amount,
    );
  }
}
