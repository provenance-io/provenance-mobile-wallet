import 'package:faker/faker.dart';
import 'package:provenance_blockchain_wallet/services/models/send_transactions.dart';
import 'package:provenance_blockchain_wallet/services/models/transaction.dart';
import 'package:provenance_blockchain_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_dart/wallet.dart';

class MockTransactionService extends TransactionService {
  final faker = Faker();

  @override
  Future<List<SendTransaction>> getSendTransactions(
    Coin coin,
    String provenanceAddress,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));
    List<SendTransaction> transactions = [];

    for (var i = 0; i < 7; i++) {
      transactions.add(_getSendTransaction());
    }

    return transactions;
  }

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
      denom: faker.randomGenerator.element([
        "nhash",
        "cfigure",
      ]),
    );
  }

  SendTransaction _getSendTransaction() {
    var amount = faker.randomGenerator.integer(999999999);
    var address1 = faker.randomGenerator
        .fromCharSet('1234567890abcdefghijklmnopqrstuvwzyz', 41);
    var address2 = faker.randomGenerator
        .fromCharSet('1234567890abcdefghijklmnopqrstuvwzyz', 41);
    var pricePerUnit = faker.randomGenerator.decimal();

    return SendTransaction.fake(
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
      exponent: 1,
    );
  }
}
