import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/screens/home/explorer/explorer_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingTab extends StatefulWidget {
  const StakingTab({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => StakingTabState();
}

class StakingTabState extends State<StakingTab> {
  late ExplorerBloc _bloc;

  final textDivider = " • ";

  @override
  void initState() {
    super.initState();
    _bloc = get<ExplorerBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.neutral750,
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<StakingDetails>(
          initialData: _bloc.stakingDetails.value,
          stream: _bloc.stakingDetails,
          builder: (context, snapshot) {
            final stakingDetails = snapshot.data;
            if (stakingDetails == null) {
              return Container();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  primary: false,
                  backgroundColor: Theme.of(context).colorScheme.neutral750,
                  elevation: 0.0,
                  title: PwText(
                    Strings.transactionDetails,
                    style: PwTextStyle.subhead,
                  ),
                  leading: Container(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.xxLarge,
                  ),
                  child: Column(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.neutral250,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: Spacing.medium,
                          ),
                          child: PwDropDown<DelegationState>(
                            initialValue: stakingDetails.selectedState,
                            items: DelegationState.values,
                            isExpanded: true,
                            onValueChanged: (item) {
                              // Change delegates
                            },
                            builder: (item) => Row(
                              children: [
                                PwText(
                                  item.dropDownTitle,
                                  color: PwColor.neutralNeutral,
                                  style: PwTextStyle.body,
                                ),
                              ],
                            ),
                          )),
                      VerticalSpacer.medium(),
                      // TODO: delegates list here.
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.neutral250,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.medium,
                        ),
                        child: PwDropDown<ValidatorStatus>(
                          initialValue: stakingDetails.selectedStatus,
                          items: ValidatorStatus.values,
                          isExpanded: true,
                          onValueChanged: (item) {
                            // Change Validators
                          },
                          builder: (item) => Row(
                            children: [
                              PwText(
                                item.dropDownTitle,
                                color: PwColor.neutralNeutral,
                                style: PwTextStyle.body,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalSpacer.medium(),
                ValidatorList(),
              ],
            );
          },
        ),
      ),
    );
  }
}
