import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/asset_service/dtos/asset_dto.dart';
import 'package:provenance_wallet/services/asset_service/dtos/asset_graph_item_dto.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/asset_graph_item.dart';
import 'package:provenance_wallet/services/notification/client_notification_mixin.dart';

class DefaultAssetService extends AssetService
    with ClientNotificationMixin, ClientCoinMixin {
  String get _assetServiceBasePath =>
      '/service-mobile-wallet/external/api/v1/address';

  @override
  Future<List<Asset>> getAssets(
    Coin coin,
    String provenanceAddresses,
  ) async {
    final client = getClient(coin);

    final data = await client.get(
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

    notifyOnError(data);

    return data.data ?? [];
  }

  String get _assetPricingBasePath =>
      '/service-mobile-wallet/external/api/v1/pricing/marker';
  @override
  Future<List<AssetGraphItem>> getAssetGraphingData(
    Coin coin,
    String assetType,
    GraphingDataValue value,
  ) async {
    final client = getClient(coin);
    final timeFrame = value.name.toUpperCase();

    final data = await client.get(
      '$_assetPricingBasePath/$assetType?period=$timeFrame',
      listConverter: (json) {
        if (json is String) {
          return <AssetGraphItem>[];
        }

        final List<AssetGraphItem> items = [];

        items.addAll(json.map((t) {
          return AssetGraphItem(dto: AssetGraphItemDto.fromJson(t));
        }).toList());

        return items..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      },
    );

    notifyOnError(data);

    return data.data ?? [];
  }
}
