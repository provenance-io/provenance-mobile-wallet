import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingManagement extends StatelessWidget {
  const StakingManagement({
    Key? key,
    required this.delegation,
  }) : super(key: key);

  final Delegation delegation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DetailsItem(
          title: Strings.stakingManagementMyDelegation,
          endChild: Flexible(
            child: PwText(
              delegation.displayDenom,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: PwTextStyle.body,
            ),
          ),
        ),
        PwListDivider(
          indent: Spacing.largeX3,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: Spacing.largeX3,
            right: Spacing.largeX3,
            top: Spacing.xLarge,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: PwButton(
                  onPressed: () {
                    // open delegate screen
                  },
                  child: PwText(
                    SelectedDelegationType.delegate.dropDownTitle,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                ),
              ),
              HorizontalSpacer.large(),
              Flexible(
                child: PwButton(
                  onPressed: () {
                    // open redelegate screen
                  },
                  child: PwText(
                    SelectedDelegationType.redelegate.dropDownTitle,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: Spacing.largeX3,
            right: Spacing.largeX3,
            top: Spacing.large,
            bottom: Spacing.xLarge,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: PwButton(
                  onPressed: () {
                    // open undelegate screen
                  },
                  child: PwText(
                    SelectedDelegationType.undelegate.dropDownTitle,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                ),
              ),
              HorizontalSpacer.large(),
              Flexible(
                child: PwButton(
                  onPressed: () {
                    // open claim rewards screen
                  },
                  child: PwText(
                    SelectedDelegationType.claimRewards.dropDownTitle,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
