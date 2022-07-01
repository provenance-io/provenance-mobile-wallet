import 'package:provenance_wallet/common/pw_design.dart';
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
                          Strings.stakingTabStakingDefined,
                          color: PwColor.neutral250,
                          style: PwTextStyle.body,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: Spacing.large),
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor:
                              Theme.of(context).colorScheme.neutralNeutral,
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
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            DelegationList(),
                            Column(
                              children: [
                                VerticalSpacer.xLarge(),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Spacing.large,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      PwText(
                                        Strings.stakingTabAvailableToSelect,
                                        color: PwColor.neutralNeutral,
                                        style: PwTextStyle.bodyBold,
                                      ),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {},
                                        child: Row(
                                          children: [
                                            PwText(
                                              Strings.stakingTabSortBy,
                                              color: PwColor.neutralNeutral,
                                              style: PwTextStyle.body,
                                            ),
                                            HorizontalSpacer.small(),
                                            PwIcon(
                                              PwIcons.sort,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .neutralNeutral,
                                            ),
                                          ],
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
