import 'package:json_annotation/json_annotation.dart';

part 'asset_statistics_dto.g.dart';

@JsonSerializable()
class AssetStatisticsDto {
  AssetStatisticsDto({
    required this.amountChange,
    required this.dayVolume,
    required this.dayHigh,
    required this.dayLow,
  });

  final double? amountChange;
  final int? dayVolume;
  final double? dayHigh;
  final double? dayLow;

  // ignore: member-ordering
  factory AssetStatisticsDto.fromJson(Map<String, dynamic> json) =>
      _$AssetStatisticsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AssetStatisticsDtoToJson(this);
}
