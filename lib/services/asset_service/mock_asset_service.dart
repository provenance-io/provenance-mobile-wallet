import 'package:faker/faker.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/asset_graph_item.dart';
import 'package:provenance_wallet/services/models/asset_statistic.dart';

class MockAssetService extends AssetService {
  final faker = Faker();
  @override
  Future<List<Asset>> getAssets(
    String provenanceAddresses,
  ) async {
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

  @override
  Future<AssetStatistics> getAssetStatistics(
    String assetType,
  ) async {
    await Future.delayed(
      Duration(
        milliseconds: faker.randomGenerator.integer(1000, min: 500),
      ),
    );

    return _getStatistic();
  }

  @override
  Future<List<AssetGraphItem>> getAssetGraphingData(
    String assetType,
    GraphingDataValue value,
  ) async {
    final List<AssetGraphItem> items = [];

    await Future.delayed(
      Duration(
        milliseconds: faker.randomGenerator.integer(1000, min: 500),
      ),
    );
    var now = DateTime.now();
    items.add(_getGraphItem(now));
    for (var i = 0; i < 100; i++) {
      items.add(_getGraphItem(now.subtract(Duration(hours: 1))));
    }

    return items;
  }

  Asset _getAsset() {
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
      usdPrice: faker.randomGenerator.decimal(min: 1),
    );
  }

  AssetStatistics _getStatistic() {
    var dayLow = faker.randomGenerator.decimal();
    var dayHigh = faker.randomGenerator.decimal(min: dayLow);

    return AssetStatistics.fake(
      amountChange: faker.randomGenerator.decimal(),
      dayVolume: faker.randomGenerator.integer(999999, min: 99999),
      dayHigh: dayHigh,
      dayLow: dayLow,
    );
  }

  AssetGraphItem _getGraphItem(DateTime timestamp) {
    double price = faker.randomGenerator.decimal();

    return AssetGraphItem.fake(timestamp: timestamp, price: price);
  }
}
