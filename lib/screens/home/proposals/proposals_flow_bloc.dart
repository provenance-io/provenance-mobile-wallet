import 'package:provenance_dart/proto_gov.dart' as gov;
import 'package:provenance_wallet/screens/home/proposals/proposals_flow.dart';
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
  Future<void> showTransactionData(Object? data, String screenTitle) async {
    await _navigator.showTransactionData(data, screenTitle);
  }

  @override
  Future<void> showTransactionComplete(
    Object? response,
    String title,
  ) async {
    await _navigator.showTransactionComplete(
      response,
      title,
    );
  }

  @override
  Future<void> showVoteReview(
      Proposal proposal, gov.VoteOption voteOption) async {
    await _navigator.showVoteReview(
      proposal,
      voteOption,
    );
  }

  @override
  Future<void> showWeightedVote(Proposal proposal) async {
    await _navigator.showWeightedVote(proposal);
  }

  @override
  Future<void> showWeightedVoteReview(Proposal proposal) async {
    await _navigator.showWeightedVoteReview(proposal);
  }

  @override
  void backToDashboard() {
    _navigator.backToDashboard();
  }

  @override
  Future<void> showDepositReview(Proposal proposal) async {
    await _navigator.showDepositReview(proposal);
  }
}
