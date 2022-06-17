import 'package:provenance_dart/src/proto/proto_gen/cosmos/gov/v1beta1/gov.pbenum.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposals_flow.dart';
import 'package:provenance_wallet/services/models/proposal.dart';

class ProposalsFlowBloc extends ProposalsFlowNavigator {
  ProposalsFlowBloc(this._navigator);

  final ProposalsFlowNavigator _navigator;

  @override
  void onComplete() {
    _navigator.onComplete();
  }

  @override
  Future<void> showProposalDetails(Proposal proposal) async {
    await _navigator.showProposalDetails(proposal);
  }

  @override
  Future<void> showTransactionData(String data) async {
    await _navigator.showTransactionData(data);
  }

  @override
  Future<void> showTransactionSuccess(String message) async {
    await _navigator.showTransactionSuccess(message);
  }

  @override
  Future<void> showVoteReview(VoteOption voteOption) async {
    await _navigator.showVoteReview(voteOption);
  }
}
