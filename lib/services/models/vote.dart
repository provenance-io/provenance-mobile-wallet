import 'package:provenance_wallet/services/governance_service/dtos/vote_dto.dart';

class Vote {
  Vote({required VoteDto dto})
      : assert(dto.blockHeight != null),
        assert(dto.proposalId != null),
        assert(dto.proposalStatus != null),
        assert(dto.proposalTitle != null),
        assert(dto.txHash != null),
        assert(dto.txTimestamp != null),
        assert(dto.voter?.address != null),
        blockHeight = dto.blockHeight!,
        proposalId = dto.proposalId!,
        proposalStatus = dto.proposalStatus!,
        proposalTitle = dto.proposalTitle!,
        txHash = dto.txHash!,
        txTimestamp = dto.txTimestamp!,
        voterAddress = dto.voter!.address!,
        answerYes = dto.answer?.VOTE_OPTION_YES,
        answerNo = dto.answer?.VOTE_OPTION_NO,
        answerNoWithVeto = dto.answer?.VOTE_OPTION_NO_WITH_VETO,
        answerAbstain = dto.answer?.VOTE_OPTION_ABSTAIN;

  Vote.fake({
    required this.proposalId,
    required this.proposalTitle,
    required this.proposalStatus,
    required this.voterAddress,
    required this.blockHeight,
    required this.txHash,
    required this.txTimestamp,
    this.answerYes,
    this.answerNo,
    this.answerNoWithVeto,
    this.answerAbstain,
  });

  final String voterAddress;
  final double? answerYes;
  final double? answerNo;
  final double? answerNoWithVeto;
  final double? answerAbstain;
  final int blockHeight;
  final String txHash;
  final DateTime txTimestamp;
  final int proposalId;
  final String proposalTitle;
  final String proposalStatus;
}
