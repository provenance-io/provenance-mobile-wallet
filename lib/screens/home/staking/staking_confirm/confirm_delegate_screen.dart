import 'package:decimal/decimal.dart';
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

class ConfirmDelegateScreen extends StatelessWidget {
  const ConfirmDelegateScreen({
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
            get<StakingFlowBloc>()
                .showTransactionData(bloc.getDelegateMessageJson());
          },
          onTransactionSign: (gasAdjustment) async {
            ModalLoadingRoute.showLoading(
              context,
              minDisplayTime: Duration(milliseconds: 500),
            );
            await _sendTransaction(bloc, details, gasAdjustment, context);
          },
          signButtonTitle:
              details.selectedDelegationType.getDropDownTitle(context),
          children: [
            DetailsHeader(title: strings.stakingConfirmDelegating),
            PwListDivider.alternate(),
            VerticalSpacer.large(),
            ValidatorCard(
              moniker: details.validator.moniker,
              imgUrl: details.validator.imgUrl,
              description: details.validator.description,
            ),
            DetailsHeader(title: strings.stakingConfirmDelegationDetails),
            PwListDivider.alternate(),
            DetailsItem.withHash(
              title: strings.stakingDelegateCurrentDelegation,
              hashString: details.delegation?.displayDenom ?? "0",
              context: context,
            ),
            PwListDivider.alternate(),
            DetailsItem.withHash(
              title: strings.stakingConfirmAmountToDelegate,
              hashString: details.hashDelegated.toString(),
              context: context,
            ),
            PwListDivider.alternate(),
            DetailsItem.withHash(
              title: strings.stakingConfirmNewTotalDelegation,
              hashString: ((details.delegation?.hashAmount ?? Decimal.zero) +
                      details.hashDelegated)
                  .toString(),
              context: context,
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendTransaction(
    StakingDelegationBloc bloc,
    StakingDelegationDetails details,
    double? gasAdjustment,
    BuildContext context,
  ) async {
    try {
      final message = await bloc.doDelegate(gasAdjustment);
      ModalLoadingRoute.dismiss(context);
      get<StakingFlowBloc>()
          .showTransactionComplete(message, details.selectedDelegationType);
    } catch (err) {
      await _showErrorModal(err, context);
    }
  }

  Future<void> _showErrorModal(Object error, BuildContext context) async {
    ModalLoadingRoute.dismiss(context);
    await showDialog(
      context: context,
      builder: (context) {
        return ErrorDialog(
          error: error.toString(),
        );
      },
    );
  }
}
