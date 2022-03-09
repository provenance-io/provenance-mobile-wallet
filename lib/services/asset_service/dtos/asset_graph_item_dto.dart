import 'package:json_annotation/json_annotation.dart';

part 'asset_graph_item_dto.g.dart';

@JsonSerializable()
class AssetGraphItemDto {
  AssetGraphItemDto({
    required this.timestamp,
    required this.price,
  });

  final String? timestamp;
  final double? price;

  // ignore: member-ordering
  factory AssetGraphItemDto.fromJson(Map<String, dynamic> json) =>
      _$AssetGraphItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AssetGraphItemDtoToJson(this);
}
