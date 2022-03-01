import 'package:faker/faker.dart';
import 'package:provenance_wallet/common/models/asset.dart';

class MockAssetService {
  Future<List<Asset>> getAssets(
    String provenanceAddresses,
  ) async {
    final faker = Faker();
    final List<Asset> assets = [];

    for (var i = 0; i < faker.randomGenerator.integer(10, min: 5); i++) {
      assets.add(_getAsset());
    }

    await Future.delayed(
      Duration(
        milliseconds: faker.randomGenerator.integer(1000, min: 500),
      ),
    );

    return assets;
  }

  Asset _getAsset() {
    var faker = Faker();
    var amount = faker.randomGenerator.decimal(min: 50).toStringAsFixed(2);

    return Asset.fake(
      denom: faker.currency.code(),
      amount: amount,
      display: faker.randomGenerator.element([
        "INU",
        "ETF",
        "USDF",
        "HASH",
      ]),
      description: "FAKE DATA",
      exponent: faker.randomGenerator.integer(10),
      displayAmount: amount,
      usdPrice: faker.randomGenerator.decimal(min: 5000),
    );
  }
}
