import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_modal/staking_modal_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/get.dart';

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
        final delegation = snapshot.data?.delegation;
        if (details == null) {
          return Container();
        }
        return ListView(
          children: [
            PwText(
              "Description",
              style: PwTextStyle.bodyBold,
            ),
            PwText(
              details.validator.description,
              style: PwTextStyle.body,
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "My Delegation",
              headerStyle: PwTextStyle.bodyBold,
              endChild: PwText(
                '${delegation?.displayDenom ?? "0 hash"} ',
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            Row(
              children: [
                PwDropDown<SelectedModalType>(
                  initialValue: SelectedModalType.undelegate,
                  items: const [
                    SelectedModalType.undelegate,
                    SelectedModalType.redelegate,
                    SelectedModalType.claimRewards,
                  ],
                  key: key,
                  isExpanded: true,
                  onValueChanged: (item) => bloc.updateSelectedModal(item),
                  builder: (item) => PwButton(
                    onPressed: () {
                      bloc.updateSelectedModal(item);
                    },
                    child: PwText(
                      item.dropDownTitle,
                      color: PwColor.neutralNeutral,
                      style: PwTextStyle.body,
                    ),
                  ),
                ),
                PwButton(
                  onPressed: () {
                    bloc.updateSelectedModal(SelectedModalType.initial);
                  },
                  child: PwText(
                    SelectedModalType.delegate.dropDownTitle,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }
}
