// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_graph_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetGraphItemDto _$AssetGraphItemDtoFromJson(Map<String, dynamic> json) =>
    AssetGraphItemDto(
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      price: (json['price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AssetGraphItemDtoToJson(AssetGraphItemDto instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp?.toIso8601String(),
      'price': instance.price,
    };
