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
  final String voterAddress;
  final int? answerYes;
  final int? answerNo;
  final int? answerNoWithVeto;
  final int? answerAbstain;
  final int blockHeight;
  final String txHash;
  final DateTime txTimestamp;
  final int proposalId;
  final String proposalTitle;
  final String proposalStatus;

  String get formattedVote {
    if (answerYes != null) {
      return "Yes";
    } else if (answerNo != null) {
      return "No";
    } else if (answerNoWithVeto != null) {
      return "No With Veto";
    } else {
      return "Abstain";
    }
  }
}
