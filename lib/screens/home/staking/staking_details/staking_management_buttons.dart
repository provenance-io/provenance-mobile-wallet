import 'package:collection/collection.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provider/provider.dart';

class StakingManagementButtons extends StatelessWidget {
  const StakingManagementButtons({
    Key? key,
    required this.validator,
    required this.delegation,
    required this.commission,
    required this.rewards,
  }) : super(key: key);
  final DetailedValidator validator;
  final Delegation? delegation;
  final Commission commission;
  final Rewards? rewards;

  @override
  Widget build(BuildContext context) {
    return delegation == null
        ? Padding(
            padding: EdgeInsets.only(
              left: Spacing.large,
              right: Spacing.large,
              top: Spacing.large,
              bottom: Spacing.xLarge,
            ),
            child: PwButton(
              onPressed: () {
                Provider.of<StakingDetailsBloc>(context, listen: false)
                    .showDelegationScreen(
                  validator,
                  commission,
                );
              },
              child: PwText(
                SelectedDelegationType.delegate.getDropDownTitle(context),
                overflow: TextOverflow.fade,
                softWrap: false,
                color: PwColor.neutralNeutral,
                style: PwTextStyle.body,
              ),
            ),
          )
        : Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: Spacing.large,
                  right: Spacing.large,
                  top: Spacing.xLarge,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: PwButton(
                        onPressed: () {
                          Provider.of<StakingDetailsBloc>(context,
                                  listen: false)
                              .showDelegationScreen(
                            validator,
                            commission,
                          );
                        },
                        child: PwText(
                          SelectedDelegationType.delegate
                              .getDropDownTitle(context),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          color: PwColor.neutralNeutral,
                          style: PwTextStyle.body,
                        ),
                      ),
                    ),
                    HorizontalSpacer.large(),
                    Flexible(
                      child: PwOutlinedButton(
                        SelectedDelegationType.redelegate
                            .getDropDownTitle(context),
                        onPressed: () {
                          Provider.of<StakingDetailsBloc>(context,
                                  listen: false)
                              .showRedelegationScreen(
                            validator,
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: Spacing.large,
                  right: Spacing.large,
                  top: Spacing.large,
                  bottom: Spacing.xLarge,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: PwOutlinedButton(
                        SelectedDelegationType.undelegate
                            .getDropDownTitle(context),
                        onPressed: () {
                          Provider.of<StakingDetailsBloc>(context,
                                  listen: false)
                              .showUndelegationScreen(
                            validator,
                          );
                        },
                      ),
                    ),
                    HorizontalSpacer.large(),
                    Flexible(
                      child: PwOutlinedButton(
                        SelectedDelegationType.claimRewards
                            .getDropDownTitle(context),
                        onPressed: () {
                          Reward? reward;
                          if (rewards != null) {
                            reward = rewards!.rewards.firstOrNull;
                          }
                          Provider.of<StakingDetailsBloc>(context,
                                  listen: false)
                              .showClaimRewardsReview(
                            validator,
                            reward,
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
  }
}
