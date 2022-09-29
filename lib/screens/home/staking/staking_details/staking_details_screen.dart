import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/delegator_details.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_management_buttons.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/validator_details.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class StakingDetailsScreen extends StatefulWidget {
  const StakingDetailsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => StakingDetailsScreenState();
}

class StakingDetailsScreenState extends State<StakingDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<StakingDetailsBloc>(context, listen: false);

    return Stack(
      children: [
        Container(
          color: Theme.of(context).colorScheme.neutral750,
          child: StreamBuilder<DetailedValidatorDetails>(
            initialData: bloc.validatorDetails.value,
            stream: bloc.validatorDetails,
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
                      ? Strings.of(context).stakingDetailsDelegation
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
                    StakingManagementButtons(
                      validator: validator,
                      delegation: details.delegation,
                      commission: commission,
                      rewards: details.rewards,
                    ),
                    VerticalSpacer.largeX3(),
                  ],
                ),
              );
            },
          ),
        ),
        StreamBuilder<bool>(
          initialData: bloc.isLoading.value,
          stream: bloc.isLoading,
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
