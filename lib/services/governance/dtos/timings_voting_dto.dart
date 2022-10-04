import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/governance/dtos/timings_voting_params_dto.dart';
import 'package:provenance_wallet/services/governance/dtos/timings_voting_tally_dto.dart';

part 'timings_voting_dto.g.dart';

@JsonSerializable()
class TimingsVotingDto {
  TimingsVotingDto({
    this.params,
    this.tally,
  });

  final TimingsVotingParamsDto? params;
  final TimingsVotingTallyDto? tally;

  // ignore: member-ordering
  factory TimingsVotingDto.fromJson(Map<String, dynamic> json) =>
      _$TimingsVotingDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TimingsVotingDtoToJson(this);
}
