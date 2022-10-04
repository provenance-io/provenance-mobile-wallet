import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/governance/dtos/timings_deposit_dto.dart';
import 'package:provenance_wallet/services/governance/dtos/timings_voting_dto.dart';
import 'package:provenance_wallet/services/governance/dtos/voting_time_dto.dart';

part 'timings_dto.g.dart';

@JsonSerializable()
class TimingsDto {
  TimingsDto({
    this.deposit,
    this.voting,
    this.submitTime,
    this.depositEndTime,
    this.votingTime,
  });

  final TimingsDepositDto? deposit;
  final TimingsVotingDto? voting;
  final DateTime? submitTime;
  final DateTime? depositEndTime;
  final VotingTimeDto? votingTime;

  // ignore: member-ordering
  factory TimingsDto.fromJson(Map<String, dynamic> json) =>
      _$TimingsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TimingsDtoToJson(this);
}
