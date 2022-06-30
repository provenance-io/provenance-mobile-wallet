import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/staking/staking_confirm/confirm_claim_rewards_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_confirm/confirm_delegate_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_confirm/confirm_redelegate_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_confirm/staking_transaction_data_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_undelegation_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_redelegation/staking_redelegation_screen.dart';
import 'package:provenance_wallet/screens/home/staking/staking_success/staking_success_screen.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/util/get.dart';

abstract class StakingFlowNavigator {
  Future<void> showDelegationScreen(
    DetailedValidator validator,
    Commission commission,
  );

  Future<void> showRedelegationScreen(
    DetailedValidator validator,
  );

  Future<void> showUndelegationScreen(
    DetailedValidator validator,
  );

  Future<void> showDelegationReview();

  Future<void> showUndelegationReview();

  Future<void> showClaimRewardsReview(
    DetailedValidator validator,
  );

  Future<void> showRedelegationReview();

  Future<void> showTransactionData(String data);

  Future<void> showTransactionSuccess(SelectedDelegationType selected);

  void onComplete();
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
  final Account account;
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
        navigator: this,
        rewards: widget.rewards,
      );

  @override
  void dispose() {
    get.unregister<StakingFlowBloc>();

    super.dispose();
  }

  @override
  void initState() {
    final bloc = StakingFlowBloc(account: widget.account, navigator: this);
    get.registerSingleton<StakingFlowBloc>(bloc);
    bloc.load();

    super.initState();
  }

  @override
  Future<void> showDelegationScreen(
    DetailedValidator validator,
    Commission commission,
  ) async {
    showPage(
      (context) => StakingDelegationScreen(
        delegation: widget.selectedDelegation,
        validator: validator,
        account: widget.account,
        commissionRate: commission.commissionRate,
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
  Future<void> showUndelegationScreen(
    DetailedValidator validator,
  ) async {
    showPage(
      (context) => StakingUndelegationScreen(
        delegation: widget.selectedDelegation,
        validator: validator,
        account: widget.account,
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
    showDelegationReview();
  }

  @override
  Future<void> showClaimRewardsReview(
    DetailedValidator validator,
  ) async {
    get.registerSingleton(
      StakingDelegationBloc(
        null,
        validator,
        "",
        SelectedDelegationType.claimRewards,
        widget.account,
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
  Future<void> showTransactionData(String data) async {
    showPage(
      (context) => StakingTransactionDataScreen(
        data: data,
      ),
    );
  }

  @override
  Future<void> showTransactionSuccess(SelectedDelegationType selected) async {
    showPage(
      (context) => StakingSuccessScreen(
        selected: selected,
      ),
    );
  }

  @override
  void onComplete() {
    completeFlow(true);
  }
}
