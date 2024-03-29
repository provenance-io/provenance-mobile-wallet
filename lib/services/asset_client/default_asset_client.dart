import 'package:intl/intl.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/asset_client/asset_client.dart';
import 'package:provenance_wallet/services/asset_client/dtos/asset_dto.dart';
import 'package:provenance_wallet/services/asset_client/dtos/asset_graph_item_dto.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/asset_graph_item.dart';
import 'package:provenance_wallet/services/notification/client_notification_mixin.dart';

class _DateTimeFormatWithTimeZone extends DateFormat {
  _DateTimeFormatWithTimeZone(String pattern) : super(pattern);

  @override
  String format(DateTime date) {
    final utcDate = date.toUtc();
    final formatted = super.format(utcDate);
    final numberFormatter = NumberFormat("00");

    final timezone = utcDate.timeZoneOffset;
    final timezoneOffsetInMinutes = timezone.inMinutes.abs();
    final offsetInHours = timezoneOffsetInMinutes ~/ 60;
    final offsetInMinutes = (timezoneOffsetInMinutes % 60);
    final prefix = timezone.inMinutes <= 0 ? "-" : "+";

    return "$formatted$prefix${numberFormatter.format(offsetInHours)}:${numberFormatter.format(offsetInMinutes)}";
  }
}

class DefaultAssetClient extends AssetClient
    with ClientNotificationMixin, ClientCoinMixin {
  static final _formatter =
      _DateTimeFormatWithTimeZone("yyyy-MM-dd'T'HH:mm:ss.SSS");
  String get _assetServiceBasePath =>
      '/service-mobile-wallet/external/api/v1/address';

  @override
  Future<List<Asset>> getAssets(
    Coin coin,
    String provenanceAddresses,
  ) async {
    final client = await getClient(coin);

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
    final client = await getClient(coin);
    final timeFrame = value.name.toUpperCase();

    String uri = '$_assetPricingBasePath/$assetType?period=$timeFrame';
    if (startDate != null) {
      uri = "$uri&startDate=${_formatter.format(startDate)}";
    }
    if (endDate != null) {
      uri = "$uri&endDate=${_formatter.format(endDate)}";
    }

    final data = await client.get(
      uri,
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

  @override
  Future<void> getHash(
    Coin coin,
    String provenanceAddress,
  ) async {
    if (coin != Coin.testNet) {
      throw "Must be on Testnet";
    }
    String uri = "https://test.provenance.io/blockchain/faucet/external";
    final client = await getClient(coin);
    await client.post(uri, body: {"address": provenanceAddress});
    return;
  }
}
