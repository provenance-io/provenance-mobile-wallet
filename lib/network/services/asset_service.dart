import 'package:flutter_tech_wallet/network/models/asset_response.dart';
import 'package:flutter_tech_wallet/network/services/base_service.dart';

class AssetService {
  static String get assetServiceBasePathv1 =>
      '/service-mobile-wallet/external/api/v1/address';

  static final AssetService _singleton = AssetService._internal();
  factory AssetService() => _singleton;
  AssetService._internal();
  static AssetService get instance => _singleton;

  static Future<BaseResponse<List<AssetResponse>>> getAssets(
      String provenanceAddresses) async {
    final data = await BaseService.instance
        .GET('$assetServiceBasePathv1/$provenanceAddresses/assets',
            listConverter: (json) {
      if (json is String) {
        return <AssetResponse>[];
      }

      final List<AssetResponse> assets = [];

      try {
        if (json is List) {
          assets.addAll(json.map((t) {
            return AssetResponse.fromJson(t);
          }).toList());
          return assets;
        }
      } catch (e) {
        return assets;
      }

      return assets;
    });
    return data;
  }
}
