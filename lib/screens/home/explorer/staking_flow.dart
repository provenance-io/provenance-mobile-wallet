import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_screen.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_details/staking_details_screen.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';

abstract class StakingFlowBlocNavigator {
  Future<void> showDelegationManagement(
    DetailedValidator validator,
    Commission commission,
  );

  Future<void> showReviewTransaction();

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
    implements StakingFlowBlocNavigator {
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
        commission: commission,
        transactionHandler: get<TransactionHandler>(),
        validatorAddress: widget.validatorAddress,
        navigator: this,
      ),
    );
  }

  @override
  Future<void> showReviewTransaction() async {}

  @override
  Future<void> showFinishedTransaction() async {}
}
