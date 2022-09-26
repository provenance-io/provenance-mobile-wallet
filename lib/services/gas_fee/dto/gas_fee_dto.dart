import 'package:json_annotation/json_annotation.dart';

part 'gas_fee_dto.g.dart';

@JsonSerializable()
class GasFeeDto {
  GasFeeDto({
    required this.gasPriceDenom,
    required this.gasPrice,
  });

  final String? gasPriceDenom;
  final int? gasPrice;

  // ignore: member-ordering
  factory GasFeeDto.fromJson(Map<String, dynamic> json) =>
      _$GasFeeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GasFeeDtoToJson(this);
}
