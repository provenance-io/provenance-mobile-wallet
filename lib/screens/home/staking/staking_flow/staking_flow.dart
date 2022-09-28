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
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_redelegation/redelegation_amount_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_redelegation/staking_redelegation_screen.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/util/get.dart';
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
  @override
  Widget createStartPage() => StakingDetailsScreen(
        validatorAddress: widget.validatorAddress,
        account: widget.account,
        selectedDelegation: widget.selectedDelegation,
        rewards: widget.rewards,
      );

  @override
  void dispose() {
    get.unregister<StakingFlowBloc>();

    super.dispose();
  }

  @override
  void initState() {
    final bloc = StakingFlowBloc(navigator: this);
    get.registerSingleton<StakingFlowBloc>(bloc);
    super.initState();
  }

  @override
  Future<void> showDelegationScreen(
    DetailedValidator validator,
    Commission commission,
  ) async {
    showPage(
      (context) => Provider<StakingDelegationBloc>(
        lazy: true,
        dispose: (_, bloc) => bloc.onDispose(),
        create: (context) {
          final bloc = StakingDelegationBloc(
            delegation: widget.selectedDelegation,
            validator: validator,
            commissionRate: commission.commissionRate,
            selectedDelegationType: SelectedDelegationType.delegate,
            account: widget.account,
          )..load();
          return bloc;
        },
        child: StakingDelegationScreen(),
      ),
    );
  }

  @override
  Future<void> showRedelegationScreen(
    DetailedValidator validator,
  ) async {
    showPage(
      (context) => StakingRedelegationScreen(
        delegation: widget.selectedDelegation!,
        validator: validator,
        account: widget.account,
      ),
    );
  }

  @override
  Future<void> showRedelegationAmountScreen() async {
    showPage(
      (context) => RedelegationAmountScreen(),
    );
  }

  @override
  Future<void> showUndelegationScreen(
    DetailedValidator validator,
  ) async {
    showPage(
      (context) => Provider<StakingDelegationBloc>(
        lazy: true,
        dispose: (_, bloc) => bloc.onDispose(),
        create: (context) {
          final bloc = StakingDelegationBloc(
            delegation: widget.selectedDelegation,
            validator: validator,
            selectedDelegationType: SelectedDelegationType.undelegate,
            account: widget.account,
          )..load();
          return bloc;
        },
        child: StakingUndelegationScreen(),
      ),
    );
  }

  @override
  Future<void> showDelegationReview() async {
    showPage(
      (context) => ConfirmDelegateScreen(),
    );
  }

  @override
  Future<void> showUndelegationReview() async {
    showPage(
      (context) => ConfirmUndelegateScreen(),
    );
  }

  @override
  Future<void> redirectToRedelegation(DetailedValidator validator) async {
    replaceLastPage(
      (context) => StakingRedelegationScreen(
        delegation: widget.selectedDelegation!,
        validator: validator,
        account: widget.account,
      ),
    );
  }

  @override
  Future<void> showClaimRewardsReview(
    DetailedValidator validator,
    Reward? reward,
  ) async {
    get.registerSingleton(
      StakingDelegationBloc(
        delegation: widget.selectedDelegation!,
        validator: validator,
        selectedDelegationType: SelectedDelegationType.claimRewards,
        account: widget.account,
        reward: reward,
      ),
    );
    showPage(
      (context) => ConfirmClaimRewardsScreen(),
    ).whenComplete(() => get.unregister<StakingDelegationBloc>());
  }

  @override
  Future<void> showRedelegationReview() async {
    showPage(
      (context) => ConfirmRedelegateScreen(),
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
        onPressed: () => showTransactionData(
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
