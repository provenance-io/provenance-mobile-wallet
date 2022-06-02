import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegate.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';

class StakingDelegationScreen extends StatefulWidget {
  final Delegation? delegation;

  final DetailedValidator validator;

  final Commission commission;
  final String validatorAddress;
  final AccountDetails accountDetails;
  final TransactionHandler transactionHandler;
  final StakingFlowBlocNavigator navigator;

  const StakingDelegationScreen({
    Key? key,
    this.delegation,
    required this.validator,
    required this.commission,
    required this.validatorAddress,
    required this.accountDetails,
    required this.transactionHandler,
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
      widget.commission,
      widget.validatorAddress,
      widget.accountDetails,
      widget.transactionHandler,
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
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundImage:
                            NetworkImage(details.validator.imgUrl ?? ""),
                        child: PwText(details.validator.moniker
                            .substring(0, 1)
                            .toUpperCase()),
                      ),
                      HorizontalSpacer.large(),
                      PwText(details.validator.moniker)
                    ],
                  ),
                  HorizontalSpacer.large(),
                  PwText("Commission - ${details.commission.commissionRate}")
                ],
              ),
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
            body: StakingDelegate(),
          );
        });
  }
}
