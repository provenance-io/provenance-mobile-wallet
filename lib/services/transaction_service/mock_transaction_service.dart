import 'package:faker/faker.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';

class MockTransactionService extends TransactionService {
  final faker = Faker();
  @override
  Future<List<Transaction>> getTransactions(
    Coin coin,
    String provenanceAddress,
    int pageNumber,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));
    List<Transaction> transactions = [];

    for (var i = 0; i < 50; i++) {
      transactions.add(_getTransaction());
    }

    return transactions;
  }

  Transaction _getTransaction() {
    var address1 = faker.randomGenerator
        .fromCharSet('1234567890abcdefghijklmnopqrstuvwzyz', 41);

    return Transaction.fake(
      block: faker.randomGenerator.integer(9999999),
      messageType: faker.randomGenerator.element([
        "Send",
        "Delegate",
        "Cancel",
        "Add_marker",
      ]),
      hash: faker.randomGenerator.fromPatternToHex([
        '################################################################',
      ]).toUpperCase(),
      signer: address1,
      status: "SUCCESS",
      time: DateTime.now(),
      feeAmount: faker.randomGenerator.integer(999999999).toString(),
    );
  }
}
