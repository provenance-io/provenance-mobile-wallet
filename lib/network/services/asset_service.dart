import 'package:provenance_wallet/network/models/asset_response.dart';
import 'package:provenance_wallet/network/services/base_service.dart';
import 'package:faker/faker.dart';

class AssetService {
  factory AssetService() => _singleton;
  AssetService._internal();

  static final AssetService _singleton = AssetService._internal();

  static String get assetServiceBasePathv1 =>
      '/service-mobile-wallet/external/api/v1/address';
  static AssetService get instance => _singleton;

  static Future<BaseResponse<List<AssetResponse>>> getAssets(
    String provenanceAddresses,
  ) async {
    final data = await BaseService.instance.GET(
      '$assetServiceBasePathv1/$provenanceAddresses/assets',
      listConverter: (json) {
        if (json is String) {
          return <AssetResponse>[];
        }

        final List<AssetResponse> assets = [];

        try {
          assets.addAll(json.map((t) {
            return AssetResponse.fromJson(t);
          }).toList());
        } catch (e) {
          return assets;
        }

        return assets;
      },
    );

    return data;
  }

// TODO: Remove me when we get actual data
  static Future<List<AssetResponse>> getFakeAssets(
    String provenanceAddresses,
  ) async {
    final faker = Faker();
    final List<AssetResponse> assets = [];

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

// TODO: Remove me when we get actual data
  static AssetResponse _getFakeAsset() {
    var faker = Faker();
    var amount = faker.randomGenerator.decimal(min: 50).toStringAsFixed(2);

    return AssetResponse(
      denom: faker.currency.code(),
      amount: amount,
      display: faker.randomGenerator.element([
        "USD",
        "USDF",
        "HASH",
      ]),
      description: "FAKE DATA",
      exponent: faker.randomGenerator.integer(10),
      displayAmount: amount,
    );
  }
}
