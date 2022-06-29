import 'package:provenance_dart/proto_gov.dart' as proto;
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_success/proposal_success_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_vote_confirm/proposal_vote_confirm_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_voting_data/proposal_voting_data_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_weighted_vote/proposal_weighted_vote_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_weighted_vote_confirm/proposal_weighted_vote_confirm.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposals_details/proposal_details_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposals_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposals_tab/proposals_tab.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/get.dart';

abstract class ProposalsFlowNavigator {
  Future<void> showProposalDetails(
    Proposal proposal,
  );

  Future<void> showVoteReview(
    Proposal proposal,
    proto.VoteOption voteOption,
  );

  Future<void> showWeightedVote(
    Proposal proposal,
  );

  Future<void> showWeightedVoteReview(
    Proposal proposal,
  );

  Future<void> showTransactionData(
    String data,
  );

  Future<void> showTransactionSuccess();

  void onComplete();
}

class ProposalsFlow extends FlowBase {
  const ProposalsFlow({
    Key? key,
    required this.account,
  }) : super(key: key);

  final TransactableAccount account;

  @override
  State<StatefulWidget> createState() => _ProposalsFlowState();
}

class _ProposalsFlowState extends FlowBaseState<ProposalsFlow>
    implements ProposalsFlowNavigator {
  @override
  void initState() {
    get.registerSingleton<ProposalsFlowBloc>(ProposalsFlowBloc(this));
    super.initState();
  }

  @override
  void dispose() {
    get.unregister<ProposalsFlowBloc>();
    super.dispose();
  }

  @override
  Widget createStartPage() => ProposalsTab();

  @override
  Future<void> showProposalDetails(
    Proposal proposal,
  ) async {
    showPage(
      (context) => ProposalDetailsScreen(
        selectedProposal: proposal,
      ),
    );
  }

  @override
  Future<void> showWeightedVote(
    Proposal proposal,
  ) async {
    showPage(
      (context) => ProposalWeightedVoteScreen(
        proposal: proposal,
        account: widget.account,
      ),
    );
  }

  @override
  Future<void> showVoteReview(
    Proposal proposal,
    proto.VoteOption voteOption,
  ) async {
    showPage(
      (context) => ProposalVoteConfirmScreen(
        account: widget.account,
        proposal: proposal,
        voteOption: voteOption,
      ),
    );
  }

  @override
  Future<void> showTransactionData(String data) async {
    showPage(
      (context) => ProposalVotingDataScreen(data: data),
    );
  }

  @override
  Future<void> showTransactionSuccess() async {
    showPage(
      (context) => ProposalSuccessScreen(),
    );
  }

  @override
  Future<void> showWeightedVoteReview(Proposal proposal) async {
    showPage(
      (context) => ProposalWeightedVoteConfirmScreen(
        account: widget.account,
        proposal: proposal,
      ),
    );
  }

  @override
  void onComplete() {
    completeFlow(true);
  }
}