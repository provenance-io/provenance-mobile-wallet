import 'package:provenance_wallet/network/models/transaction_response.dart';
import 'package:provenance_wallet/network/services/base_service.dart';
import 'package:faker/faker.dart';

class TransactionService {
  factory TransactionService() => _singleton;
  TransactionService._internal();

  static final TransactionService _singleton = TransactionService._internal();

  static String get transactionServiceBasePath =>
      '/service-mobile-wallet/external/api/v1/address';
  static TransactionService get instance => _singleton;

  static Future<BaseResponse<List<TransactionResponse>>> getTransactions(
    String provenanceAddresses,
  ) async {
    final data = await BaseService.instance.GET(
      '$transactionServiceBasePath/$provenanceAddresses/transactions',
      listConverter: (json) {
        if (json is String) {
          return <TransactionResponse>[];
        }

        final List<TransactionResponse> transactions = [];

        try {
          transactions.addAll(json.map((t) {
            return TransactionResponse.fromJson(t);
          }).toList());
        } catch (e) {
          return transactions;
        }

        return transactions;
      },
    );

    return data;
  }

// TODO: Remove me when we get actual data
  static Future<List<TransactionResponse>> getFakeTransactions(
    String provenanceAddresses,
  ) async {
    final faker = Faker();
    final List<TransactionResponse> transactions = [];

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

// TODO: Remove me when we get actual data
  static TransactionResponse _getFakeTransaction() {
    var faker = Faker();
    var amount = faker.randomGenerator.decimal().toStringAsFixed(2);

    return TransactionResponse(
      address:
          faker.randomGenerator.fromPatternToHex(['########################']),
      feeAmount: amount,
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
