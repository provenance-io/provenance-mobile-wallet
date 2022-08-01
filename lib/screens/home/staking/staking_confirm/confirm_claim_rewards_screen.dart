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
    final strings = Strings.of(context);

    return StreamBuilder<StakingDelegationDetails>(
      initialData: bloc.stakingDelegationDetails.value,
      stream: bloc.stakingDelegationDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;
        if (details == null) {
          return Container();
        }

        return StakingConfirmBase(
          appBarTitle: details.selectedDelegationType.getDropDownTitle(context),
          onDataClick: () {
            get<StakingFlowBloc>().showTransactionData(
              bloc.getClaimRewardJson(),
              Strings.of(context).stakingConfirmData,
            );
          },
          onTransactionSign: (gasAdjustment) async {
            ModalLoadingRoute.showLoading(
              context,
              minDisplayTime: Duration(milliseconds: 500),
            );
            await _sendTransaction(
                gasAdjustment, details.selectedDelegationType, context);
          },
          signButtonTitle:
              Strings.of(context).stakingDelegationBlocClaimRewards,
          children: [
            DetailsHeader(title: strings.stakingConfirmClaimRewardsDetails),
            PwListDivider.alternate(),
            VerticalSpacer.large(),
            PwText(
              strings.stakingRedelegateFrom,
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
              title: strings.stakingDelegateCurrentDelegation,
              hashString: details.delegation?.displayDenom ??
                  strings.stakingManagementNoHash,
              context: context,
            ),
            PwListDivider.alternate(),
            DetailsItem.withHash(
              title: strings.stakingConfirmRewardsAvailable,
              hashString: details.reward?.formattedAmount ??
                  strings.stakingManagementNoHash,
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
      final message =
          await (get<StakingDelegationBloc>()).claimRewards(gasAdjustment);
      ModalLoadingRoute.dismiss(context);
      get<StakingFlowBloc>().showTransactionComplete(message, selected);
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
