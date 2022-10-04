import 'package:json_annotation/json_annotation.dart';

part 'stat_dto.g.dart';

@JsonSerializable()
class StatDto {
  StatDto({
    required this.marketCap,
    required this.validators,
    required this.transactions,
    required this.averageBlockTime,
  });

  final double? marketCap;
  final int? validators;
  final int? transactions;
  final double? averageBlockTime;

  // ignore: member-ordering
  factory StatDto.fromJson(Map<String, dynamic> json) =>
      _$StatDtoFromJson(json);
  Map<String, dynamic> toJson() => _$StatDtoToJson(this);
}
