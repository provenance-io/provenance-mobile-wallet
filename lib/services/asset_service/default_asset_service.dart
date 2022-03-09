import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/asset_service/dtos/asset_dto.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/notification/client_notification_mixin.dart';
import 'package:provenance_wallet/services/notification/notification_client_id.dart';
import 'package:provenance_wallet/util/get.dart';

class DefaultAssetService extends AssetService with ClientNotificationMixin {
  String get _assetServiceBasePath =>
      '/service-mobile-wallet/external/api/v1/address';

  @override
  Future<List<Asset>> getAssets(
    String provenanceAddresses,
  ) async {
    final data = await get<HttpClient>().get(
      '$_assetServiceBasePath/$provenanceAddresses/assets',
      listConverter: (json) {
        if (json is String) {
          return <Asset>[];
        }

        final List<Asset> assets = [];

        assets.addAll(json.map((t) {
          return Asset(dto: AssetDto.fromJson(t));
        }).toList());

        return assets;
      },
    );

    notifyOnError(data, serviceMobileWalletClientId);

    return data.data ?? [];
  }
}
