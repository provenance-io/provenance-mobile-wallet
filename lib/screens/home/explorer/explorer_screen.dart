import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/explorer_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking/staking_tab.dart';
import 'package:provenance_wallet/screens/home/tab_item.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/strings.dart';

class ExplorerScreen extends StatefulWidget {
  ExplorerScreen({
    Key? key,
    required this.accountDetails,
  }) : super(key: key);

  AccountDetails accountDetails;
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<ExplorerScreen>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    RouterObserver.instance.routeObserver.unsubscribe(this);
    _tabController.removeListener(_setCurrentTab);
    _tabController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    RouterObserver.instance.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_setCurrentTab);
    WidgetsBinding.instance.addObserver(this);
    final bloc = ExplorerBloc(accountDetails: widget.accountDetails);
    get.registerSingleton<ExplorerBloc>(bloc);
    bloc.load();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTallScreen = (mediaQuery.size.height > 600);

    final double topPadding = (isTallScreen) ? 10 : 5;
    final double bottomPadding = (isTallScreen) ? 28 : 5;

    return Scaffold(
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.neutral800,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VerticalSpacer.large(),
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.transparent,
              tabs: [
                TabItem(
                  0 == _currentTabIndex,
                  Strings.staking,
                  PwIcons.staking,
                  topPadding: topPadding,
                  bottomPadding: bottomPadding,
                ),
                TabItem(
                  1 == _currentTabIndex,
                  Strings.proposals,
                  PwIcons.hashLogo,
                  topPadding: topPadding,
                  bottomPadding: bottomPadding,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: const [
                  StakingTab(),
                  Center(
                    child: PwText(Strings.proposals),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setCurrentTab() {
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }
}
