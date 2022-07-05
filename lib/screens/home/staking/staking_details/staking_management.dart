import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingManagement extends StatelessWidget {
  const StakingManagement({
    Key? key,
    required this.validator,
    required this.delegation,
    required this.commission,
  }) : super(key: key);
  final DetailedValidator validator;
  final Delegation delegation;
  final Commission commission;

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
                    get<StakingFlowBloc>().showDelegationScreen(
                      validator,
                      commission,
                    );
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
                    get<StakingFlowBloc>().showRedelegationScreen(
                      validator,
                    );
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
                    get<StakingFlowBloc>().showUndelegationScreen(
                      validator,
                    );
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
                    get<StakingFlowBloc>().showClaimRewardsReview(validator);
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
