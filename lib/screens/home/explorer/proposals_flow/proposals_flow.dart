import 'package:provenance_dart/proto_gov.dart' as proto;
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals/proposal_details_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals/proposals_tab.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/services/models/rewards.dart';

abstract class ProposalsFlowNavigator {
  Future<void> showProposalDetails(
    Proposal proposal,
  );

  Future<void> showVoteReview(
    proto.VoteOption voteOption,
  );

  Future<void> showTransactionData(
    String data,
  );

  Future<void> showTransactionSuccess(
    String message,
  );

  void onComplete();
}

class ProposalsFlow extends FlowBase {
  const ProposalsFlow(
    this.validatorAddress,
    this.account,
    this.selectedDelegation,
    this.rewards, {
    Key? key,
  }) : super(key: key);

  final String validatorAddress;
  final TransactableAccount account;
  final Delegation? selectedDelegation;
  final Rewards? rewards;

  @override
  State<StatefulWidget> createState() => _ProposalsFlowState();
}

class _ProposalsFlowState extends FlowBaseState<ProposalsFlow>
    implements ProposalsFlowNavigator {
  @override
  Widget createStartPage() => ProposalsTab();

  @override
  Future<void> showProposalDetails(
    Proposal proposal,
  ) async {
    showPage(
      (context) => ProposalDetailsScreen(selectedProposal: proposal),
    );
  }

  @override
  Future<void> showVoteReview(
    proto.VoteOption voteOption,
  ) async {
    showPage(
      // FIXME
      (context) => Container(),
    );
  }

  @override
  Future<void> showTransactionData(String data) async {
    showPage(
      // FIXME
      (context) => Container(),
    );
  }

  @override
  Future<void> showTransactionSuccess(String message) async {
    showPage(
      // FIXME
      (context) => Container(),
    );
  }

  @override
  void onComplete() {
    completeFlow(true);
  }
}
