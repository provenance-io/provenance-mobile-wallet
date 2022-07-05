import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/delegator_details.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_management.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/validator_details.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingDetailsScreen extends StatefulWidget {
  const StakingDetailsScreen({
    Key? key,
    required this.validatorAddress,
    required this.account,
    required this.selectedDelegation,
    required this.rewards,
  }) : super(key: key);

  final String validatorAddress;
  final Account account;
  final Delegation? selectedDelegation;
  final Rewards? rewards;

  @override
  State<StatefulWidget> createState() => StakingDetailsScreenState();
}

class StakingDetailsScreenState extends State<StakingDetailsScreen> {
  late final StakingDetailsBloc _bloc;

  @override
  void initState() {
    _bloc = StakingDetailsBloc(
      widget.validatorAddress,
      widget.account,
      widget.selectedDelegation,
      widget.rewards,
    );
    _bloc.load();
    get.registerSingleton<StakingDetailsBloc>(_bloc);
    super.initState();
  }

  @override
  void dispose() {
    get.unregister<StakingDetailsBloc>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).colorScheme.neutral750,
          child: StreamBuilder<DetailedValidatorDetails>(
            initialData: _bloc.validatorDetails.value,
            stream: _bloc.validatorDetails,
            builder: (context, snapshot) {
              final details = snapshot.data;
              final validator = snapshot.data?.validator;
              final commission = snapshot.data?.commission;
              if (details == null || validator == null || commission == null) {
                return Container();
              }

              return Scaffold(
                appBar: PwAppBar(
                  title: details.delegation == null
                      ? Strings.stakingDetailsDelegation
                      : validator.moniker,
                  leadingIcon: PwIcons.back,
                  style: PwTextStyle.footnote,
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding:
                            EdgeInsets.symmetric(horizontal: Spacing.large),
                        children: [
                          if (details.delegation == null)
                            ValidatorDetails(validator: validator),
                          DelegatorDetails(details: details),
                        ],
                      ),
                    ),
                    StakingManagement(
                      validator: validator,
                      delegation: details.delegation,
                      commission: commission,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        StreamBuilder<bool>(
          initialData: _bloc.isLoading.value,
          stream: _bloc.isLoading,
          builder: (context, snapshot) {
            final isLoading = snapshot.data ?? false;
            if (isLoading) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Container();
          },
        ),
      ],
    );
  }
}
