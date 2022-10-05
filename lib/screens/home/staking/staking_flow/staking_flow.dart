import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_data_screen.dart';
import 'package:provenance_wallet/common/widgets/pw_transaction_complete_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_confirm/confirm_claim_rewards_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_confirm/confirm_delegate_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_confirm/confirm_redelegate_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_confirm/confirm_undelegate_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_undelegation_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_redelegation/redelegation_amount_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_redelegation/staking_redelegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_redelegation/staking_redelegation_screen.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

abstract class StakingFlowNavigator {
  Future<void> showDelegationScreen(
    DetailedValidator validator,
    Commission commission,
  );

  Future<void> showRedelegationScreen(
    DetailedValidator validator,
  );

  Future<void> redirectToRedelegation(
    DetailedValidator validator,
  );

  Future<void> showRedelegationAmountScreen();

  Future<void> showUndelegationScreen(
    DetailedValidator validator,
  );

  Future<void> showDelegationReview();

  Future<void> showUndelegationReview();

  Future<void> showClaimRewardsReview(
    DetailedValidator validator,
    Reward? reward,
  );

  Future<void> showRedelegationReview();

  Future<void> showTransactionData(
    Object? data,
    String screenTitle,
  );

  Future<void> showTransactionComplete(
    Object? response,
    SelectedDelegationType selected,
  );

  void onComplete();

  void backToDashboard();
}

class StakingFlow extends FlowBase {
  const StakingFlow(
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
  State<StatefulWidget> createState() => StakingFlowState();
}

class StakingFlowState extends FlowBaseState<StakingFlow>
    implements StakingFlowNavigator {
  StakingDelegationBloc? _delegationBloc;
  StakingRedelegationBloc? _redelegationBloc;

  @override
  Widget build(BuildContext context) {
    return Provider<StakingDetailsBloc>(
        lazy: true,
        create: (context) {
          final bloc = StakingDetailsBloc(
            widget.validatorAddress,
            widget.account,
            widget.selectedDelegation,
            widget.rewards,
            navigator: this,
          )..load();
          return bloc;
        },
        dispose: (_, bloc) {
          bloc.onDispose();
        },
        child: super.build(context));
  }

  @override
  void dispose() {
    _delegationBloc?.onDispose();
    _redelegationBloc?.onDispose();
    super.dispose();
  }

  @override
  Widget createStartPage() => StakingDetailsScreen();

  @override
  Future<void> showDelegationScreen(
    DetailedValidator validator,
    Commission commission,
  ) async {
    _delegationBloc = StakingDelegationBloc(
      delegation: widget.selectedDelegation,
      validator: validator,
      commissionRate: commission.commissionRate,
      selectedDelegationType: SelectedDelegationType.delegate,
      account: widget.account,
    )..load();
    showPage(
      (context) => Provider.value(
        value: _delegationBloc!,
        child: StakingDelegationScreen(),
      ),
    );
  }

  @override
  Future<void> showRedelegationScreen(
    DetailedValidator validator,
  ) async {
    _redelegationBloc = StakingRedelegationBloc(
      validator,
      widget.selectedDelegation!,
      widget.account,
    )..load();
    showPage(
      (context) => Provider.value(
        value: _redelegationBloc,
        child: StakingRedelegationScreen(),
      ),
    );
  }

  @override
  Future<void> showRedelegationAmountScreen() async {
    showPage(
      (context) => Provider.value(
        value: _redelegationBloc,
        child: RedelegationAmountScreen(),
      ),
    );
  }

  @override
  Future<void> showUndelegationScreen(
    DetailedValidator validator,
  ) async {
    _delegationBloc = StakingDelegationBloc(
      delegation: widget.selectedDelegation,
      validator: validator,
      selectedDelegationType: SelectedDelegationType.undelegate,
      account: widget.account,
    )..load();
    showPage(
      (context) => Provider.value(
        value: _delegationBloc,
        child: StakingUndelegationScreen(),
      ),
    );
  }

  @override
  Future<void> showDelegationReview() async {
    showPage(
      (context) => Provider.value(
        value: _delegationBloc,
        child: ConfirmDelegateScreen(),
      ),
    );
  }

  @override
  Future<void> showUndelegationReview() async {
    showPage(
      (context) => Provider.value(
        value: _delegationBloc,
        child: ConfirmUndelegateScreen(),
      ),
    );
  }

  @override
  Future<void> redirectToRedelegation(DetailedValidator validator) async {
    _delegationBloc = StakingDelegationBloc(
      delegation: widget.selectedDelegation,
      validator: validator,
      selectedDelegationType: SelectedDelegationType.undelegate,
      account: widget.account,
    )..load();
    replaceLastPage(
      (context) => Provider.value(
        value: _delegationBloc,
        child: StakingUndelegationScreen(),
      ),
    );
  }

  @override
  Future<void> showClaimRewardsReview(
    DetailedValidator validator,
    Reward? reward,
  ) async {
    _delegationBloc = StakingDelegationBloc(
      delegation: widget.selectedDelegation!,
      validator: validator,
      selectedDelegationType: SelectedDelegationType.claimRewards,
      account: widget.account,
      reward: reward,
    )..load();
    showPage(
      (context) => Provider.value(
        value: _delegationBloc,
        child: ConfirmClaimRewardsScreen(),
      ),
    );
  }

  @override
  Future<void> showRedelegationReview() async {
    showPage(
      (context) => Provider.value(
        value: _redelegationBloc,
        child: ConfirmRedelegateScreen(),
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
      Object? response, SelectedDelegationType selected) async {
    showPage(
      (context) => PwTransactionCompleteScreen(
        title: selected.getCompletionMessage(context),
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
  void onComplete() {
    completeFlow(true);
  }

  @override
  void backToDashboard() {
    completeFlow(false);
  }
}
