import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegate.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_management.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_redelegate.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_undelegate.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';

class StakingDelegationScreen extends StatefulWidget {
  final Delegation? delegation;

  final DetailedValidator validator;

  final String commissionRate;
  final AccountDetails accountDetails;
  final StakingFlowNavigator navigator;

  const StakingDelegationScreen({
    Key? key,
    this.delegation,
    required this.validator,
    required this.commissionRate,
    required this.accountDetails,
    required this.navigator,
  }) : super(key: key);

  @override
  State<StakingDelegationScreen> createState() =>
      _StakingDelegationScreenState();
}

class _StakingDelegationScreenState extends State<StakingDelegationScreen> {
  late final StakingDelegationBloc _bloc;

  @override
  void initState() {
    _bloc = StakingDelegationBloc(
      widget.delegation,
      widget.validator,
      widget.commissionRate,
      widget.accountDetails,
    );
    get.registerSingleton<StakingDelegationBloc>(_bloc);
    _bloc.load();
    super.initState();
  }

  @override
  void dispose() {
    get.unregister<StakingDelegationBloc>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StakingDelegationDetails>(
      initialData: _bloc.stakingDelegationDetails.value,
      stream: _bloc.stakingDelegationDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;

        if (null == details) {
          return Container();
        }

        return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.neutral750,
              elevation: 0.0,
              centerTitle: true,
              title: PwText(details.validator.moniker),
              leading: Padding(
                padding: EdgeInsets.only(left: 21),
                child: IconButton(
                  icon: PwIcon(
                    PwIcons.back,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            body: _getBody(details.selectedDelegationType));
      },
    );
  }

  Widget _getBody(SelectedDelegationType type) {
    switch (type) {
      case SelectedDelegationType.initial:
        return StakingManagement();
      case SelectedDelegationType.delegate:
        return StakingDelegate(
          navigator: widget.navigator,
        );
      case SelectedDelegationType.claimRewards:
        widget.navigator.showReviewTransaction(type);
        return Center(
          child: CircularProgressIndicator(),
        );
      case SelectedDelegationType.undelegate:
        return StakingUndelegate(
          navigator: widget.navigator,
        );
      case SelectedDelegationType.redelegate:
        return StakingRedelegate(
          navigator: widget.navigator,
          accountDetails: widget.accountDetails,
          delegation: widget.delegation!,
        );
    }
  }
}
