import 'package:provenance_wallet/network/models/asset_response.dart';
import 'package:provenance_wallet/network/services/base_service.dart';

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
}
