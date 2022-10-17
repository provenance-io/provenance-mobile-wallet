import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:provenance_dart/proto_cosmos_gov_v1beta1.dart' as gov;
import 'package:provenance_wallet/common/classes/transaction_bloc.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/services/models/vote.dart';

class ProposalVoteConfirmBloc extends TransactionBloc {
  final Proposal _proposal;
  final gov.VoteOption _voteOption;

  ProposalVoteConfirmBloc(
    TransactableAccount account,
    this._proposal,
    this._voteOption,
  ) : super(account);

  @override
  gov.MsgVote getMessage() {
    return gov.MsgVote(
      option: _voteOption,
      proposalId: Int64.parseInt(_proposal.proposalId.toString()),
      voter: account.address,
    );
  }

  Vote getUserFriendlyVote() {
    switch (_voteOption) {
      case gov.VoteOption.VOTE_OPTION_ABSTAIN:
        return Vote.demo(answerAbstain: 1);
      case gov.VoteOption.VOTE_OPTION_NO:
        return Vote.demo(answerNo: 1);
      case gov.VoteOption.VOTE_OPTION_NO_WITH_VETO:
        return Vote.demo(answerNoWithVeto: 1);
      case gov.VoteOption.VOTE_OPTION_YES:
        return Vote.demo(answerYes: 1);
      default:
        // Won't get here, but I have to have this for safety reasons.
        return Vote.demo();
    }
  }

  @override
  FutureOr onDispose() {}
}
