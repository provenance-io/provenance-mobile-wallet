import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/home/staking/staking_confirm/staking_confirm_base.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/validator_card.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ConfirmClaimRewardsScreen extends StatelessWidget {
  const ConfirmClaimRewardsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = get<StakingDelegationBloc>();

    return StreamBuilder<StakingDelegationDetails>(
      initialData: bloc.stakingDelegationDetails.value,
      stream: bloc.stakingDelegationDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;
        if (details == null) {
          return Container();
        }

        return StakingConfirmBase(
          appBarTitle: details.selectedDelegationType.dropDownTitle,
          onDataClick: () {
            get<StakingFlowBloc>()
                .showTransactionData(bloc.getClaimRewardJson());
          },
          onTransactionSign: (gasAdjustment) async {
            ModalLoadingRoute.showLoading(context);
            // Give the loading modal time to display
            await Future.delayed(Duration(milliseconds: 500));
            await _sendTransaction(
                gasAdjustment, details.selectedDelegationType, context);
          },
          signButtonTitle: Strings.stakingDelegationBlocClaimRewards,
          children: [
            DetailsHeader(title: Strings.stakingConfirmClaimRewardsDetails),
            PwListDivider.alternate(),
            VerticalSpacer.large(),
            PwText(
              Strings.stakingRedelegateFrom,
              color: PwColor.neutral200,
            ),
            VerticalSpacer.small(),
            ValidatorCard(
              moniker: details.validator.moniker,
              imgUrl: details.validator.imgUrl,
              description: details.validator.description,
            ),
            VerticalSpacer.largeX3(),
            PwListDivider.alternate(),
            DetailsItem.withHash(
              title: Strings.stakingDelegateCurrentDelegation,
              hashString: details.delegation?.displayDenom ??
                  Strings.stakingManagementNoHash,
              context: context,
            ),
            PwListDivider.alternate(),
            DetailsItem.withHash(
              title: Strings.stakingConfirmRewardsAvailable,
              hashString: details.reward?.formattedAmount ??
                  Strings.stakingManagementNoHash,
              context: context,
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendTransaction(
    double? gasAdjustment,
    SelectedDelegationType selected,
    BuildContext context,
  ) async {
    try {
      await (get<StakingDelegationBloc>()).claimRewards(gasAdjustment);
      ModalLoadingRoute.dismiss(context);
      get<StakingFlowBloc>().showTransactionSuccess(selected);
    } catch (err) {
      ModalLoadingRoute.dismiss(context);
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
            error: err.toString(),
          );
        },
      );
    }
  }
}
