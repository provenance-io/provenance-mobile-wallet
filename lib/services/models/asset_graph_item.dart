import 'package:provenance_blockchain_wallet/services/asset_service/dtos/asset_graph_item_dto.dart';

class AssetGraphItem {
  AssetGraphItem({required AssetGraphItemDto dto})
      : assert(dto.timestamp != null),
        assert(dto.price != null),
        timestamp = dto.timestamp!,
        price = dto.price!;

  AssetGraphItem.fake({
    required this.timestamp,
    required this.price,
  });

  final DateTime timestamp;
  final double price;
}
