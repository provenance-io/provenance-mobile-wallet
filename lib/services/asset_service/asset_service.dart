import 'package:provenance_wallet/services/asset_service/dtos/asset_graph_item_dto.dart';
import 'package:provenance_wallet/services/asset_service/dtos/asset_statistics_dto.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/util/strings.dart';

class AssetService {
  Future<List<Asset>> getAssets(
    String provenanceAddresses,
  ) {
    throw Strings.notImplementedMessage;
  }

  Future<AssetStatisticsDto> getAssetStatistics(
    String assetType,
  ) {
    throw Strings.notImplementedMessage;
  }

  Future<List<AssetGraphItemDto>> getAssetGraphingData(
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
  allTime,
}
