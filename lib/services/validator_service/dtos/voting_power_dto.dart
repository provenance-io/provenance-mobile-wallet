import 'package:json_annotation/json_annotation.dart';

part 'voting_power_dto.g.dart';

@JsonSerializable()
class VotingPowerDto {
  VotingPowerDto({
    this.count,
    this.total,
  });
  final int? count;
  final int? total;

  // ignore: member-ordering
  factory VotingPowerDto.fromJson(Map<String, dynamic> json) =>
      _$VotingPowerDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VotingPowerDtoToJson(this);
}
