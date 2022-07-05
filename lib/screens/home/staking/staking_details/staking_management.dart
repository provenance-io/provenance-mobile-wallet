import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';

class StakingManagement extends StatelessWidget {
  const StakingManagement({
    Key? key,
    required this.validator,
    required this.delegation,
    required this.commission,
  }) : super(key: key);
  final DetailedValidator validator;
  final Delegation? delegation;
  final Commission commission;

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
                      child: PwOutlinedButton(
                        SelectedDelegationType.redelegate.dropDownTitle,
                        onPressed: () {
                          get<StakingFlowBloc>().showRedelegationScreen(
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
                        SelectedDelegationType.undelegate.dropDownTitle,
                        onPressed: () {
                          get<StakingFlowBloc>().showUndelegationScreen(
                            validator,
                          );
                        },
                      ),
                    ),
                    HorizontalSpacer.large(),
                    Flexible(
                      child: PwOutlinedButton(
                        SelectedDelegationType.claimRewards.dropDownTitle,
                        onPressed: () {
                          get<StakingFlowBloc>()
                              .showClaimRewardsReview(validator);
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
