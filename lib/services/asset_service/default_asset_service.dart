import 'package:intl/intl.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/extension/date_time.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/asset_service/dtos/asset_dto.dart';
import 'package:provenance_wallet/services/asset_service/dtos/asset_graph_item_dto.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/asset_graph_item.dart';
import 'package:provenance_wallet/services/notification/client_notification_mixin.dart';

class _DateTimeFormatWithTimeZone extends DateFormat {
  _DateTimeFormatWithTimeZone(String pattern) : super(pattern);

  @override
  String format(DateTime date) {
    final formatted = super.format(date);
    final numberFormatter = NumberFormat("00");

    final timezone = date.timeZoneOffset;
    final offsetInHours = timezone.inMinutes ~/ 60;
    final offsetInMinutes = (timezone.inMinutes % 60).abs();

    return "$formatted${numberFormatter.format(offsetInHours)}:${numberFormatter.format(offsetInMinutes)}";
  }
}

class DefaultAssetService extends AssetService
    with ClientNotificationMixin, ClientCoinMixin {
  @visibleForTesting
  static final formatter =
      _DateTimeFormatWithTimeZone("yyyy-MM-dd'T'HH:mm:ss.SSS");
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
    GraphingDataValue value, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    startDate ??= DateTime.now().startOfDay;
    endDate ??= DateTime.now().endOfDay;
    final client = getClient(coin);
    final timeFrame = value.name.toUpperCase();

    final data = await client.get(
      '$_assetPricingBasePath/$assetType?period=$timeFrame&startDate=${formatter.format(startDate)}&endDate=${formatter.format(endDate)}',
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
