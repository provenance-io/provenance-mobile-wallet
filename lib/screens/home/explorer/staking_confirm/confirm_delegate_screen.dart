import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_confirm/staking_confirm_base.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/extensions/num_extensions.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ConfirmDelegateScreen extends StatelessWidget {
  const ConfirmDelegateScreen({Key? key, required this.navigator})
      : super(key: key);

  final StakingFlowBlocNavigator navigator;

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
          appBarTitle: details.selectedModalType.dropDownTitle,
          onDataClick: () {
            final data = '''{
  "delegatorAddress": "${details.accountDetails.address}",
  "validatorAddress": "${details.validator.operatorAddress}",
  "amount": {
    "denom": "nhash",
    "amount": "${details.hashDelegated.nhashFromHash()}"
  }
}''';
            navigator.showTransactionData(data);
          },
          onTransactionSign: (gasEstimated) {},
          children: [
            DetailsItem(
              title: Strings.stakingConfirmDelegatorAddress,
              endChild: Flexible(
                child: PwText(
                  details.accountDetails.address.abbreviateAddress(),
                  overflow: TextOverflow.ellipsis,
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
                  overflow: TextOverflow.ellipsis,
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
                  overflow: TextOverflow.ellipsis,
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
                  details.hashDelegated.nhashFromHash(),
                  overflow: TextOverflow.ellipsis,
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
}
