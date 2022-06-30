import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/screens/home/staking/delegation_list.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/validator_list.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingScreen extends StatefulWidget {
  const StakingScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StakingScreenState();
}

class _StakingScreenState extends State<StakingScreen>
    with TickerProviderStateMixin {
  late StakingScreenBloc _bloc;
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_setCurrentTab);
    _bloc = StakingScreenBloc();
    get.registerSingleton(_bloc);
    _bloc.load();
  }

  @override
  void dispose() {
    _tabController.removeListener(_setCurrentTab);
    _tabController.dispose();
    get.unregister<StakingScreenBloc>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
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
                        backgroundColor:
                            Theme.of(context).colorScheme.neutral750,
                        elevation: 0.0,
                        title: PwText(
                          Strings.staking,
                          style: PwTextStyle.footnote,
                        ),
                        leading: Padding(
                          padding: EdgeInsets.only(left: 21),
                          child: IconButton(
                            icon: PwIcon(
                              PwIcons.back,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.large,
                          vertical: Spacing.largeX3,
                        ),
                        child: PwText(
                          "Staking is a process that involves committing your assets to support Provenance's network and to confirm transactions.",
                          color: PwColor.neutral250,
                          style: PwTextStyle.body,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        indicatorPadding:
                            EdgeInsets.symmetric(horizontal: Spacing.large),
                        tabs: [
                          Padding(
                            padding: EdgeInsets.only(bottom: Spacing.small),
                            child: PwText(
                              Strings.stakingTabMyDelegations,
                              color: _currentTabIndex == 0
                                  ? PwColor.neutralNeutral
                                  : PwColor.neutral250,
                              style: PwTextStyle.footnote,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: Spacing.small),
                            child: PwText(
                              Strings.validators,
                              color: _currentTabIndex == 1
                                  ? PwColor.neutralNeutral
                                  : PwColor.neutral250,
                              style: PwTextStyle.footnote,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            DelegationList(),
                            Column(
                              children: [
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
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .neutral250,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4)),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: Spacing.medium,
                                          ),
                                          child:
                                              PwDropDown<ValidatorSortingState>(
                                            value: stakingDetails.selectedSort,
                                            items: ValidatorSortingState.values,
                                            isExpanded: true,
                                            onValueChanged: (item) {
                                              _bloc.updateSort(item);
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
                            ),
                          ],
                        ),
                      ),
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
      ),
    );
  }

  void _setCurrentTab() {
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }
}
