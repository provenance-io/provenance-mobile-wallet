import 'package:json_annotation/json_annotation.dart';

part 'voting_time_dto.g.dart';

@JsonSerializable()
class VotingTimeDto {
  VotingTimeDto({
    this.startTime,
    this.endTime,
  });

  final DateTime? startTime;
  final DateTime? endTime;

  // ignore: member-ordering
  factory VotingTimeDto.fromJson(Map<String, dynamic> json) =>
      _$VotingTimeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VotingTimeDtoToJson(this);
}
