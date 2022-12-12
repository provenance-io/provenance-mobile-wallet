import 'package:json_annotation/json_annotation.dart';

part 'gas_markup_dto.g.dart';

@JsonSerializable()
class GasPriceDto {
  GasPriceDto({
    required this.denom,
    required this.amount,
  });

  @JsonKey(name: 'gasPriceDenom')
  final String? denom;

  @JsonKey(name: 'gasPrice')
  final double? amount;

  // ignore: member-ordering
  factory GasPriceDto.fromJson(Map<String, dynamic> json) =>
      _$GasPriceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GasPriceDtoToJson(this);
}
