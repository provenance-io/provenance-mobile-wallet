import 'package:provenance_wallet/services/asset_client/dtos/asset_graph_item_dto.dart';

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

  AssetGraphItem copyWith({
    double? newPrice,
    DateTime? newTimestamp,
  }) {
    return AssetGraphItem(
      dto: AssetGraphItemDto(
        timestamp: newTimestamp ?? timestamp,
        price: newPrice ?? price,
      ),
    );
  }
}
