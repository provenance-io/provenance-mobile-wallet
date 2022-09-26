import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/governance/dtos/proposer_dto.dart';
import 'package:provenance_wallet/services/governance/dtos/vote_answer_dto.dart';

part 'vote_dto.g.dart';

@JsonSerializable()
class VoteDto {
  VoteDto({
    this.txHash,
    this.txTimestamp,
    this.proposalId,
    this.proposalTitle,
    this.proposalStatus,
    this.voter,
    this.answer,
    this.blockHeight,
  });

  final ProposerDto? voter;
  final VoteAnswerDto? answer;
  final int? blockHeight;
  final String? txHash;
  final DateTime? txTimestamp;
  final int? proposalId;
  final String? proposalTitle;
  final String? proposalStatus;

  // ignore: member-ordering
  factory VoteDto.fromJson(Map<String, dynamic> json) =>
      _$VoteDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VoteDtoToJson(this);
}
