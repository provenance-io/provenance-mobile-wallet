import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/home/staking/staking_confirm/staking_confirm_base.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/validator_card.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_redelegation/staking_redelegation_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ConfirmRedelegateScreen extends StatelessWidget {
  const ConfirmRedelegateScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = get<StakingRedelegationBloc>();
    final strings = Strings.of(context);

    return StreamBuilder<StakingRedelegationDetails>(
      initialData: bloc.stakingRedelegationDetails.value,
      stream: bloc.stakingRedelegationDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;
        if (details == null) {
          return Container();
        }
        return StakingConfirmBase(
          appBarTitle: details.selectedDelegationType.getDropDownTitle(context),
          onDataClick: () {
            get<StakingFlowBloc>().showTransactionData(
              bloc.getRedelegateMessageJson(),
              Strings.of(context).stakingConfirmData,
            );
          },
          onTransactionSign: (gasAdjustment) async {
            ModalLoadingRoute.showLoading(
              context,
              minDisplayTime: Duration(milliseconds: 500),
            );
            await _sendTransaction(
              bloc,
              details.selectedDelegationType,
              gasAdjustment,
              context,
            );
          },
          signButtonTitle:
              details.selectedDelegationType.getDropDownTitle(context),
          children: [
            DetailsHeader(title: strings.stakingConfirmRedelegationDetails),
            PwListDivider.alternate(),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: Spacing.small,
              ),
              child: PwText(
                strings.stakingRedelegateFrom,
                color: PwColor.neutral200,
              ),
            ),
            ValidatorCard(
              moniker: details.validator.moniker,
              imgUrl: details.validator.imgUrl,
              description: details.validator.description,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: Spacing.small,
              ),
              child: PwText(
                strings.stakingRedelegateTo,
                color: PwColor.neutral200,
              ),
            ),
            ValidatorCard(
              moniker: details.toRedelegate!.moniker,
              imgUrl: details.toRedelegate!.imgUrl,
            ),
            VerticalSpacer.largeX3(),
            PwListDivider.alternate(),
            DetailsItem.withHash(
              title: strings.stakingDelegateCurrentDelegation,
              hashString: details.delegation.displayDenom,
              context: context,
            ),
            PwListDivider.alternate(),
            DetailsItem.withHash(
              title: strings.stakingConfirmAmountToRedelegate,
              hashString: details.hashRedelegated.toString(),
              context: context,
            ),
            PwListDivider.alternate(),
            DetailsItem.withHash(
              title: strings.stakingConfirmNewTotalDelegation,
              hashString:
                  (details.delegation.hashAmount - details.hashRedelegated)
                      .toString(),
              context: context,
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendTransaction(
    StakingRedelegationBloc bloc,
    SelectedDelegationType selected,
    double? gasAdjustment,
    BuildContext context,
  ) async {
    try {
      final message =
          await (get<StakingRedelegationBloc>()).doRedelegate(gasAdjustment);
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
