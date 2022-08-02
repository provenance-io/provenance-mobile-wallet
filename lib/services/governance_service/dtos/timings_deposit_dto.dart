import 'package:json_annotation/json_annotation.dart';

part 'timings_deposit_dto.g.dart';

@JsonSerializable()
class TimingsDepositDto {
  TimingsDepositDto({
    this.initial,
    this.current,
    this.needed,
    this.denom,
  });

  final String? initial;
  final String? current;
  final String? needed;
  final String? denom;

  // ignore: member-ordering
  factory TimingsDepositDto.fromJson(Map<String, dynamic> json) =>
      _$TimingsDepositDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TimingsDepositDtoToJson(this);
}
