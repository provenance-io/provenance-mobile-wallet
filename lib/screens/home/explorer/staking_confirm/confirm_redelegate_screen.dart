import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_confirm/staking_confirm_base.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_redelegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/extensions/num_extensions.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ConfirmRedelegateScreen extends StatelessWidget {
  const ConfirmRedelegateScreen({Key? key, required this.navigator})
      : super(key: key);

  final StakingFlowNavigator navigator;

  @override
  Widget build(BuildContext context) {
    final bloc = get<StakingRedelegationBloc>();

    return StreamBuilder<StakingRedelegationDetails>(
      initialData: bloc.stakingRedelegationDetails.value,
      stream: bloc.stakingRedelegationDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;
        if (details == null) {
          return Container();
        }
        return StakingConfirmBase(
          appBarTitle: details.selectedDelegationType.dropDownTitle,
          onDataClick: () {
            final data = '''
{
  "delegatorAddress": "${details.accountDetails.address}",
  "validatorSrcAddress": "${details.delegation.address}",
  "validatorDstAddress": "${details.toRedelegate?.address}",
  "amount": {
    "denom": "nhash",
    "amount": "${details.hashRedelegated.nhashFromHash()}"
  }
}
''';
            navigator.showTransactionData(data);
          },
          onTransactionSign: (gasEstimated) async {
            ModalLoadingRoute.showLoading('', context);
            // Give the loading modal time to display
            await Future.delayed(Duration(milliseconds: 500));
            await _sendTransaction(bloc, gasEstimated, context);
          },
          signButtonTitle: details.selectedDelegationType.dropDownTitle,
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
                  details.delegation.address.abbreviateAddress(),
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
                  Strings.stakingConfirmHash,
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
                  details.hashRedelegated.nhashFromHash(),
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
    StakingRedelegationBloc bloc,
    double gasEstimated,
    BuildContext context,
  ) async {
    await (get<StakingRedelegationBloc>())
        .doRedelegate(gasEstimated)
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
