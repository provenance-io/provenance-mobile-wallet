import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingManagement extends StatelessWidget {
  const StakingManagement({
    Key? key,
    required this.navigator,
  }) : super(key: key);

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
        return ListView(
          children: [
            DetailsItem(
              title: Strings.stakingManagementDescription,
              endChild: Flexible(
                child: PwText(
                  details.validator.description,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: PwTextStyle.body,
                ),
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.stakingManagementMyDelegation,
              endChild: Flexible(
                child: PwText(
                  details.delegation?.displayDenom ??
                      Strings.stakingManagementNoHash,
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
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.largeX3,
                vertical: Spacing.xLarge,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: PwDropDown<SelectedDelegationType>(
                      initialValue: SelectedDelegationType.undelegate,
                      items: const [
                        SelectedDelegationType.undelegate,
                        SelectedDelegationType.redelegate,
                        SelectedDelegationType.claimRewards,
                      ],
                      key: key,
                      icon: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary550,
                              spreadRadius: 8,
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.5),
                          child: PwIcon(
                            PwIcons.chevron,
                            color: Theme.of(context).colorScheme.neutralNeutral,
                          ),
                        ),
                      ),
                      isExpanded: true,
                      onValueChanged: (item) {
                        bloc.updateSelectedDelegationType(item);
                        if (item == SelectedDelegationType.claimRewards) {
                          navigator.showReviewTransaction(item);
                        }
                      },
                      builder: (item) => Container(
                        height: 42,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary550,
                            )
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: PwText(
                                item.dropDownTitle,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                color: PwColor.neutralNeutral,
                                style: PwTextStyle.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  HorizontalSpacer.large(),
                  Flexible(
                      child: PwButton(
                    onPressed: () {
                      bloc.updateSelectedDelegationType(
                        SelectedDelegationType.delegate,
                      );
                    },
                    child: PwText(
                      SelectedDelegationType.delegate.dropDownTitle,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      color: PwColor.neutralNeutral,
                      style: PwTextStyle.body,
                    ),
                  ))
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
