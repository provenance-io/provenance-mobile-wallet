import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/governance_service/dtos/tally_amount_dto.dart';

part 'timings_voting_tally_dto.g.dart';

@JsonSerializable()
class TimingsVotingTallyDto {
  TimingsVotingTallyDto({
    this.yes,
    this.no,
    this.noWithVeto,
    this.abstain,
    this.total,
  });

  final TallyAmountDto? yes;
  final TallyAmountDto? no;
  final TallyAmountDto? noWithVeto;
  final TallyAmountDto? abstain;
  final TallyAmountDto? total;

  // ignore: member-ordering
  factory TimingsVotingTallyDto.fromJson(Map<String, dynamic> json) =>
      _$TimingsVotingTallyDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TimingsVotingTallyDtoToJson(this);
}
