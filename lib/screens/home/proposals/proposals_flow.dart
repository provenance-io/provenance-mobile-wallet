import 'package:provenance_dart/proto_gov.dart' as proto;
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_data_screen.dart';
import 'package:provenance_wallet/common/widgets/pw_transaction_complete_screen.dart';
import 'package:provenance_wallet/screens/home/proposals/deposit_confirm/deposit_confirm_screen.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_vote_confirm/proposal_vote_confirm_screen.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote/proposal_weighted_vote_screen.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote_confirm/proposal_weighted_vote_confirm.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_details/proposal_details_screen.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_screen.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class ProposalsFlowNavigator {
  Future<void> showProposalDetails(
    Proposal proposal,
  );

  Future<void> showVoteReview(
    Proposal proposal,
    proto.VoteOption voteOption,
  );

  Future<void> showDepositReview(
    Proposal proposal,
  );

  Future<void> showWeightedVote(
    Proposal proposal,
  );

  Future<void> showWeightedVoteReview(
    Proposal proposal,
  );

  Future<void> showTransactionData(
    Object? data,
    String screenTitle,
  );

  Future<void> showTransactionComplete(Object? response);

  void onComplete();

  void backToDashboard();
}

class ProposalsFlow extends FlowBase {
  const ProposalsFlow({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProposalsFlowState();
}

class _ProposalsFlowState extends FlowBaseState<ProposalsFlow>
    implements ProposalsFlowNavigator {
  late TransactableAccount _account;
  @override
  void initState() {
    _account = get<AccountService>().events.selected.value!;
    get.registerSingleton<ProposalsFlowBloc>(ProposalsFlowBloc(this));
    get.registerSingleton(ProposalsBloc(account: _account)..load());
    super.initState();
  }

  @override
  void dispose() {
    get.unregister<ProposalsFlowBloc>();
    get.unregister<ProposalsBloc>();
    super.dispose();
  }

  @override
  Widget createStartPage() => ProposalsScreen();

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
        account: _account,
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
        account: _account,
        proposal: proposal,
        voteOption: voteOption,
      ),
    );
  }

  @override
  Future<void> showTransactionData(Object? data, String screenTitle) async {
    showPage(
      (context) => PwDataScreen(
        title: screenTitle,
        data: data,
      ),
    );
  }

  @override
  Future<void> showTransactionComplete(Object? response) async {
    showPage(
      (context) => PwTransactionCompleteScreen(
        title: Strings.of(context).proposalVoteComplete,
        onBackToDashboard: backToDashboard,
        response: response,
        onComplete: onComplete,
        onPressed: () => showTransactionData(
          response,
          Strings.of(context).transactionResponse,
        ),
      ),
    );
  }

  @override
  Future<void> showWeightedVoteReview(Proposal proposal) async {
    showPage(
      (context) => ProposalWeightedVoteConfirmScreen(
        account: _account,
        proposal: proposal,
      ),
    );
  }

  @override
  Future<void> showDepositReview(Proposal proposal) async {
    showPage(
      (context) => DepositConfirmScreen(
        account: _account,
        proposal: proposal,
      ),
    );
  }

  @override
  void onComplete() {
    completeFlow(true);
  }

  @override
  void backToDashboard() {
    completeFlow(false);
  }
}
