import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_confirm/confirm_delegate_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_confirm/confirm_redelegate_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_details/staking_details_screen.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';

abstract class StakingFlowNavigator {
  void goBack();

  Future<void> showDelegationManagement(
    DetailedValidator validator,
    Commission commission,
  );

  Future<void> showReviewTransaction(SelectedDelegationType type);

  Future<void> showTransactionData(String data);

  Future<void> showFinishedTransaction();
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
  void goBack() {
    Navigator.of(context).pop();
  }

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
        validatorAddress: widget.validatorAddress,
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
        // FIXME: use correct view.
        widget = ConfirmRedelegateScreen(
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

// TODO: have the caller make the string.
  @override
  Future<void> showTransactionData(String data) async {
//     String data;
//     switch (type) {
//       case SelectedDelegationType.initial:
//         return;
//       case SelectedDelegationType.undelegate:
//       case SelectedDelegationType.delegate:
//         data = '''
// {
//   "delegatorAddress": "${widget.details.address}",
//   "validatorAddress": "${widget.validatorAddress}",
//   "amount": {
//     "denom": "nhash",
//     "amount": "${details.hashDelegated.nhashFromHash()}"
//   }
// }
// ''';
//         break;
//       case SelectedDelegationType.claimRewards:
//         data = '''
// {
//   "delegatorAddress": "${widget.details.address}",
//   "validatorAddress": "${widget.validatorAddress}",
// }
// ''';
//         break;
//       case SelectedDelegationType.redelegate:
//         data = '''
// {
//   "delegatorAddress": "${widget.details.address}",
//   "validatorSrcAddress": "${widget.validatorAddress}",
//   "validatorDstAddress": "${validator!.address}",
//   "amount": {
//     "denom": "nhash",
//     "amount": "${details.hashDelegated.nhashFromHash()}"
//   }
// }
// ''';
//         break;
//     }
  }

  @override
  Future<void> showFinishedTransaction() async {}
}
