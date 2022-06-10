import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_confirm/confirm_claim_rewards_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_confirm/confirm_delegate_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_confirm/confirm_redelegate_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_confirm/staking_transaction_data_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_details/staking_details_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_success/staking_success_screen.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';

abstract class StakingFlowNavigator {
  Future<void> showDelegationManagement(
    DetailedValidator validator,
    Commission commission,
  );

  Future<void> showReviewTransaction(SelectedDelegationType type);

  Future<void> showTransactionData(String data);

  Future<void> showTransactionSuccess();

  void onComplete();
}

class StakingFlow extends FlowBase {
  const StakingFlow(
    this.validatorAddress,
    this.details,
    this.selectedDelegation, {
    Key? key,
  }) : super(key: key);

  final String validatorAddress;
  final AccountDetails details;
  final Delegation? selectedDelegation;

  @override
  State<StatefulWidget> createState() => StakingFlowState();
}

class StakingFlowState extends FlowBaseState<StakingFlow>
    implements StakingFlowNavigator {
  @override
  Widget createStartPage() => StakingDetailsScreen(
        validatorAddress: widget.validatorAddress,
        details: widget.details,
        selectedDelegation: widget.selectedDelegation,
        navigator: this,
      );

  @override
  Future<void> showDelegationManagement(
    DetailedValidator validator,
    Commission commission,
  ) async {
    showPage(
      (context) => StakingDelegationScreen(
        delegation: widget.selectedDelegation,
        validator: validator,
        accountDetails: widget.details,
        commissionRate: commission.commissionRate,
        navigator: this,
      ),
    );
  }

  @override
  Future<void> showReviewTransaction(SelectedDelegationType type) async {
    Widget widget;
    switch (type) {
      case SelectedDelegationType.initial:
        return;
      case SelectedDelegationType.undelegate:
      case SelectedDelegationType.delegate:
        widget = ConfirmDelegateScreen(
          navigator: this,
        );
        break;
      case SelectedDelegationType.claimRewards:
        widget = ConfirmClaimRewardsScreen(
          navigator: this,
        );
        break;
      case SelectedDelegationType.redelegate:
        widget = ConfirmRedelegateScreen(
          navigator: this,
        );
        break;
    }
    showPage(
      (context) => widget,
    );
  }

  @override
  Future<void> showTransactionData(String data) async {
    showPage(
      (context) => StakingTransactionDataScreen(
        data: data,
        navigator: this,
      ),
    );
  }

  @override
  Future<void> showTransactionSuccess() async {
    showPage(
      (context) => StakingSuccessScreen(
        navigator: this,
      ),
    );
  }

  @override
  void onComplete() {
    completeFlow(null);
  }
}
