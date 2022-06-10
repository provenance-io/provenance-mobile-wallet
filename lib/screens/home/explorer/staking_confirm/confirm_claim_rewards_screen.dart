import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_confirm/staking_confirm_base.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ConfirmClaimRewardsScreen extends StatelessWidget {
  const ConfirmClaimRewardsScreen({Key? key, required this.navigator})
      : super(key: key);

  final StakingFlowNavigator navigator;

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
  "delegatorAddress": "${details.accountDetails.address}",
  "validatorAddress": "${details.validator.operatorAddress}",
}''';
            navigator.showTransactionData(data);
          },
          onTransactionSign: (gasEstimated) async {
            ModalLoadingRoute.showLoading('', context);
            // Give the loading modal time to display
            await Future.delayed(Duration(milliseconds: 500));
            await _sendTransaction(gasEstimated, context);
          },
          children: [
            DetailsItem(
              title: Strings.stakingConfirmDelegatorAddress,
              endChild: Flexible(
                child: PwText(
                  details.accountDetails.address.abbreviateAddress(),
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
          ],
        );
      },
    );
  }

  Future<void> _sendTransaction(
    double gasEstimated,
    BuildContext context,
  ) async {
    await (get<StakingDelegationBloc>())
        .claimRewards(gasEstimated)
        .then((value) {
      ModalLoadingRoute.dismiss(context);
      navigator.showTransactionSuccess();
    }).catchError(
      (err) {
        ModalLoadingRoute.dismiss(context);
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              error: err.toString(),
            );
          },
        );
      },
    );
  }
}
