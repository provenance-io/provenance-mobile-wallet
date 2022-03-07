// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_statistics_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetStatisticsDto _$AssetStatisticsDtoFromJson(Map<String, dynamic> json) =>
    AssetStatisticsDto(
      amountChange: (json['amountChange'] as num?)?.toDouble(),
      dayVolume: json['dayVolume'] as int?,
      dayHigh: (json['dayHigh'] as num?)?.toDouble(),
      dayLow: (json['dayLow'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AssetStatisticsDtoToJson(AssetStatisticsDto instance) =>
    <String, dynamic>{
      'amountChange': instance.amountChange,
      'dayVolume': instance.dayVolume,
      'dayHigh': instance.dayHigh,
      'dayLow': instance.dayLow,
    };
