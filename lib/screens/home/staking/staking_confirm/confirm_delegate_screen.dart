import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/home/staking/staking_confirm/staking_confirm_base.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/denom_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ConfirmDelegateScreen extends StatelessWidget {
  const ConfirmDelegateScreen({
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
            final data = '''{
  "delegatorAddress": "${details.account.publicKey!.address}",
  "validatorAddress": "${details.validator.operatorAddress}",
  "amount": {
    "denom": "nhash",
    "amount": "${hashToNHash(details.hashDelegated)}"
  }
}''';
            get<StakingFlowBloc>().showTransactionData(data);
          },
          onTransactionSign: (gasAdjustment) async {
            ModalLoadingRoute.showLoading('', context);
            // Give the loading modal time to display
            await Future.delayed(Duration(milliseconds: 500));
            await _sendTransaction(bloc, details, gasAdjustment, context);
          },
          signButtonTitle: details.selectedDelegationType.dropDownTitle,
          children: [
            DetailsItem(
              title: Strings.stakingConfirmDelegatorAddress,
              endChild: Flexible(
                child: PwText(
                  details.account.publicKey!.address.abbreviateAddress(),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  color: PwColor.neutralNeutral,
                  style: PwTextStyle.body,
                ),
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.stakingConfirmValidatorAddress,
              endChild: Flexible(
                child: PwText(
                  details.validator.operatorAddress.abbreviateAddress(),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  color: PwColor.neutralNeutral,
                  style: PwTextStyle.body,
                ),
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.stakingConfirmDenom,
              endChild: Flexible(
                child: PwText(
                  details.asset?.denom ?? Strings.stakingConfirmHash,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  color: PwColor.neutralNeutral,
                  style: PwTextStyle.body,
                ),
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.stakingConfirmAmount,
              endChild: Flexible(
                child: PwText(
                  hashToNHash(details.hashDelegated).toString(),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  color: PwColor.neutralNeutral,
                  style: PwTextStyle.body,
                ),
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
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
    final selected = details.selectedDelegationType;
    if (SelectedDelegationType.delegate == selected) {
      try {
        await bloc.doDelegate(gasAdjustment);
        ModalLoadingRoute.dismiss(context);
        get<StakingFlowBloc>().showTransactionSuccess(selected);
      } catch (err) {
        await _showErrorModal(err, context);
      }
    } else {
      try {
        await bloc.doUndelegate(gasAdjustment);
        ModalLoadingRoute.dismiss(context);
        get<StakingFlowBloc>().showTransactionSuccess(selected);
      } catch (err) {
        await _showErrorModal(err, context);
      }
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
