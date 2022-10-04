import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/asset_graph_item.dart';
import 'package:provenance_wallet/util/strings.dart';

class AssetClient {
  Future<List<Asset>> getAssets(
    Coin coin,
    String provenanceAddresses,
  ) {
    throw Strings.notImplementedMessage;
  }

  Future<List<AssetGraphItem>> getAssetGraphingData(
    Coin coin,
    String assetType,
    GraphingDataValue value, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    throw Strings.notImplementedMessage;
  }
}

enum GraphingDataValue {
  minute,
  hourly,
  daily,
  weekly,
  monthly,
  yearly,
  all,
}
