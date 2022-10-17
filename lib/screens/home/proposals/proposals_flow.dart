import 'package:provenance_dart/proto_cosmos_gov_v1beta1.dart' as proto;
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_data_screen.dart';
import 'package:provenance_wallet/common/widgets/pw_transaction_complete_screen.dart';
import 'package:provenance_wallet/screens/home/proposals/deposit_confirm/deposit_confirm_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/deposit_confirm/deposit_confirm_screen.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_details/proposal_details_screen.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_vote_confirm/proposal_vote_confirm_screen.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote/proposal_weighted_vote_screen.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote/weighted_vote_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote_confirm/proposal_weighted_vote_confirm.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_screen.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

import 'proposal_vote_confirm/proposal_vote_confirm_bloc.dart';

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

  Future<void> showTransactionComplete(
    Object? response,
    String title,
  );

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
  WeightedVoteBloc? _weightedVoteBloc;
  @override
  void initState() {
    _account = get<AccountService>().events.selected.value!;
    super.initState();
  }

  @override
  void dispose() {
    _weightedVoteBloc?.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ProposalsBloc>(
        lazy: true,
        create: (context) {
          final bloc = ProposalsBloc(
            navigator: this,
            account: _account,
          )..load();
          return bloc;
        },
        dispose: (_, bloc) {
          bloc.onDispose();
        },
        child: super.build(context));
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
    _weightedVoteBloc = WeightedVoteBloc(
      proposal,
      _account,
    );
    showPage(
      (context) => Provider.value(
        value: _weightedVoteBloc,
        child: ProposalWeightedVoteScreen(
          proposal: proposal,
          account: _account,
        ),
      ),
    );
  }

  @override
  Future<void> showVoteReview(
    Proposal proposal,
    proto.VoteOption voteOption,
  ) async {
    showPage(
      (context) => Provider<ProposalVoteConfirmBloc>(
        lazy: true,
        create: (context) {
          return ProposalVoteConfirmBloc(
            _account,
            proposal,
            voteOption,
          );
        },
        dispose: (_, bloc) {
          bloc.onDispose();
        },
        child: ProposalVoteConfirmScreen(
          account: _account,
          proposal: proposal,
        ),
      ),
    );
  }

  @override
  Future<void> showTransactionData(
    Object? data,
    String screenTitle,
  ) async {
    showPage(
      (context) => PwDataScreen(
        title: screenTitle,
        data: data,
      ),
    );
  }

  @override
  Future<void> showTransactionComplete(
    Object? response,
    String title,
  ) async {
    showPage(
      (context) => PwTransactionCompleteScreen(
        title: title,
        onBackToDashboard: backToDashboard,
        response: response,
        onComplete: onComplete,
        onDataPressed: () => showTransactionData(
          response,
          Strings.of(context).transactionResponse,
        ),
      ),
    );
  }

  @override
  Future<void> showWeightedVoteReview(Proposal proposal) async {
    showPage(
      (context) => Provider.value(
        value: _weightedVoteBloc,
        child: ProposalWeightedVoteConfirmScreen(
          proposal: proposal,
          account: _account,
        ),
      ),
    );
  }

  @override
  Future<void> showDepositReview(Proposal proposal) async {
    showPage(
      (context) => Provider<DepositConfirmBloc>(
        lazy: true,
        create: (context) {
          final bloc = DepositConfirmBloc(
            _account,
            proposal,
          )..load();

          return bloc;
        },
        dispose: (_, bloc) {
          bloc.onDispose();
        },
        child: DepositConfirmScreen(),
      ),
    );
  }

  @override
  void onComplete() {
    backToFlowStart(null);
  }

  @override
  void backToDashboard() {
    completeFlow(false);
  }
}
