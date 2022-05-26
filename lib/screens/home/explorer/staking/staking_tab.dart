import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/screens/home/explorer/explorer_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking/delegation_list.dart';
import 'package:provenance_wallet/screens/home/explorer/staking/validator_list.dart';
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
    return Stack(
      children: [
        Container(
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
                        Strings.staking,
                        style: PwTextStyle.subhead,
                      ),
                      leading: Padding(
                        padding: EdgeInsets.only(left: 21),
                        child: IconButton(
                          icon: PwIcon(
                            PwIcons.close,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.xxLarge,
                      ),
                      child: Row(
                        children: [
                          PwText(
                            Strings.dropDownDelegateHeader,
                            color: PwColor.neutralNeutral,
                            style: PwTextStyle.body,
                          ),
                          HorizontalSpacer.large(),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.neutral250,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: Spacing.medium,
                              ),
                              child: PwDropDown<DelegationState>(
                                initialValue: stakingDetails.selectedState,
                                items: DelegationState.values,
                                isExpanded: true,
                                onValueChanged: (item) {
                                  _bloc.updateState(item);
                                },
                                builder: (item) => PwText(
                                  item.dropDownTitle,
                                  color: PwColor.neutralNeutral,
                                  style: PwTextStyle.body,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    DelegationList(),
                    VerticalSpacer.medium(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.xxLarge,
                      ),
                      child: Row(
                        children: [
                          PwText(
                            Strings.dropDownStateHeader,
                            color: PwColor.neutralNeutral,
                            style: PwTextStyle.body,
                          ),
                          HorizontalSpacer.large(),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.neutral250,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: Spacing.medium,
                              ),
                              child: PwDropDown<ValidatorStatus>(
                                initialValue: stakingDetails.selectedStatus,
                                items: ValidatorStatus.values,
                                isExpanded: true,
                                onValueChanged: (item) {
                                  _bloc.updateStatus(item);
                                },
                                builder: (item) => PwText(
                                  item.dropDownTitle,
                                  color: PwColor.neutralNeutral,
                                  style: PwTextStyle.body,
                                ),
                              ),
                            ),
                          )
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
        ),
        StreamBuilder<bool>(
          initialData: _bloc.isLoading.value,
          stream: _bloc.isLoading,
          builder: (context, snapshot) {
            final isLoading = snapshot.data ?? false;
            if (isLoading) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Container();
          },
        ),
      ],
    );
  }
}