import 'package:provenance_wallet/services/asset_service/dtos/asset_graph_item_dto.dart';

class AssetGraphItem {
  AssetGraphItem({required AssetGraphItemDto dto})
      : assert(dto.timestamp != null),
        assert(dto.price != null),
        timestamp = DateTime.parse(dto.timestamp!),
        price = dto.price!;

  AssetGraphItem.fake({
    required this.timestamp,
    required this.price,
  });

  final DateTime timestamp;
  final double price;
}
