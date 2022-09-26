import 'package:faker/faker.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/gas_fee/gas_fee_client.dart';
import 'package:provenance_wallet/services/models/gas_fee.dart';

class MockGasFeeClient extends GasFeeClient {
  final faker = Faker();

  @override
  Future<GasFee?> getGasFee(Coin coin) async {
    return Future.delayed(
      Duration(
        milliseconds: faker.randomGenerator.integer(1000, min: 500),
      ),
      () => _getGasFee(),
    );
  }

  GasFee _getGasFee() {
    var amount = faker.randomGenerator.integer(10000);

    return GasFee.fake(
      denom: faker.currency.code(),
      amount: amount,
    );
  }
}
