import 'package:json_annotation/json_annotation.dart';

part 'commission_rate_dto.g.dart';

@JsonSerializable()
class CommissionRateDto {
  CommissionRateDto({
    this.rate,
    this.maxRate,
    this.maxChangeRate,
  });
  final String? rate;
  final String? maxRate;
  final String? maxChangeRate;

  // ignore: member-ordering
  factory CommissionRateDto.fromJson(Map<String, dynamic> json) =>
      _$CommissionRateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CommissionRateDtoToJson(this);
}
