import 'package:faker/faker.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/gas_fee/gas_fee_client.dart';
import 'package:provenance_wallet/services/models/gas_price.dart';

class MockGasFeeClient extends GasFeeClient {
  final faker = Faker();

  @override
  Future<GasPrice?> getPrice(Coin coin) async {
    return Future.delayed(
      Duration(
        milliseconds: faker.randomGenerator.integer(1000, min: 500),
      ),
      () => _getGasFee(),
    );
  }

  GasPrice _getGasFee() {
    var amount = faker.randomGenerator.integer(10000);

    return GasPrice(
      denom: faker.currency.code(),
      amountPerUnit: amount,
    );
  }
}
