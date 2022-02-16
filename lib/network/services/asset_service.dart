import 'package:provenance_wallet/common/models/asset.dart';
import 'package:provenance_wallet/network/dtos/asset_dto.dart';
import 'package:provenance_wallet/network/services/base_service.dart';
import 'package:faker/faker.dart';

class AssetService {
  String get _assetServiceBasePathv1 =>
      '/service-mobile-wallet/external/api/v1/address';

  Future<BaseResponse<List<Asset>>> getAssets(
    String provenanceAddresses,
  ) async {
    final data = await BaseService.instance.GET(
      '$_assetServiceBasePathv1/$provenanceAddresses/assets',
      listConverter: (json) {
        if (json is String) {
          return <Asset>[];
        }

        final List<Asset> assets = [];

        try {
          assets.addAll(json.map((t) {
            return Asset(dto: AssetDto.fromJson(t));
          }).toList());
        } catch (e) {
          return assets;
        }

        return assets;
      },
    );

    return data;
  }

// TODO: Remove me when we can mock
  Future<List<Asset>> getFakeAssets(
    String provenanceAddresses,
  ) async {
    final faker = Faker();
    final List<Asset> assets = [];

    for (var i = 0; i < faker.randomGenerator.integer(10, min: 5); i++) {
      assets.add(_getFakeAsset());
    }

    await Future.delayed(
      Duration(
        milliseconds: faker.randomGenerator.integer(1000, min: 500),
      ),
    );

    return assets;
  }

// TODO: Remove me when we can mock
  Asset _getFakeAsset() {
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
    );
  }
}
