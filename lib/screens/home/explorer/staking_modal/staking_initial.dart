import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_modal/staking_modal_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingInitial extends StatelessWidget {
  const StakingInitial({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = get<StakingModalBloc>();

    return StreamBuilder<StakingModalDetails>(
      initialData: bloc.stakingModalDetails.value,
      stream: bloc.stakingModalDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;
        if (details == null) {
          return Container();
        }
        return ListView(
          children: [
            DetailsItem(
              title: Strings.stakingInitialDescription,
              endChild: Flexible(
                child: PwText(
                  details.validator.description,
                  overflow: TextOverflow.ellipsis,
                  style: PwTextStyle.body,
                ),
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.stakingInitialMyDelegation,
              endChild: Flexible(
                child: PwText(
                  details.delegation?.displayDenom ??
                      Strings.stakingInitialNoHash,
                  overflow: TextOverflow.ellipsis,
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
                    child: PwDropDown<SelectedModalType>(
                      initialValue: SelectedModalType.undelegate,
                      items: const [
                        SelectedModalType.undelegate,
                        SelectedModalType.redelegate,
                        SelectedModalType.claimRewards,
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
                      onValueChanged: (item) => bloc.updateSelectedModal(item),
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
                            PwText(
                              item.dropDownTitle,
                              overflow: TextOverflow.ellipsis,
                              color: PwColor.neutralNeutral,
                              style: PwTextStyle.body,
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
                      bloc.updateSelectedModal(SelectedModalType.initial);
                    },
                    child: PwText(
                      SelectedModalType.delegate.dropDownTitle,
                      overflow: TextOverflow.ellipsis,
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
