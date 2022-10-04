import 'package:json_annotation/json_annotation.dart';

part 'asset_dto.g.dart';

@JsonSerializable()
class AssetDto {
  AssetDto({
    required this.denom,
    required this.amount,
    required this.display,
    required this.description,
    required this.exponent,
    required this.displayAmount,
    required this.usdPrice,
    this.dailyHigh,
    this.dailyLow,
    this.dailyVolume,
  });

  final String? denom;
  final String? amount;
  final String? display;
  final String? description;
  final int? exponent;
  final String? displayAmount;
  final double? usdPrice;
  final double? dailyHigh;
  final double? dailyLow;
  final double? dailyVolume;

  // ignore: member-ordering
  factory AssetDto.fromJson(Map<String, dynamic> json) =>
      _$AssetDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AssetDtoToJson(this);
}
