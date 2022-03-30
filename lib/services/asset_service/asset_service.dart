import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/asset_graph_item.dart';
import 'package:provenance_wallet/util/strings.dart';

class AssetService {
  Future<List<Asset>> getAssets(
    String provenanceAddresses,
  ) {
    throw Strings.notImplementedMessage;
  }

  Future<List<AssetGraphItem>> getAssetGraphingData(
    String assetType,
    GraphingDataValue value,
  ) {
    throw Strings.notImplementedMessage;
  }
}

enum GraphingDataValue {
  hourly,
  daily,
  weekly,
  monthly,
  yearly,
  all,
}
