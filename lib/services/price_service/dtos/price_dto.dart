import 'package:json_annotation/json_annotation.dart';

part 'price_dto.g.dart';

@JsonSerializable()
class PriceDto {
  PriceDto({
    required this.markerDenom,
    required this.usdPrice,
  });

  final String? markerDenom;
  final double? usdPrice;

  // ignore: member-ordering
  factory PriceDto.fromJson(Map<String, dynamic> json) =>
      _$PriceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PriceDtoToJson(this);
}
