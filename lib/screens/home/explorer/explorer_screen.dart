import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposals_flow.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposals_tab/proposals_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_tab/staking_tab.dart';
import 'package:provenance_wallet/screens/home/tab_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/strings.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({
    Key? key,
    required this.account,
  }) : super(key: key);

  final TransactableAccount account;
  @override
  State<StatefulWidget> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    RouterObserver.instance.routeObserver.unsubscribe(this);
    _tabController.removeListener(_setCurrentTab);
    _tabController.dispose();
    get.unregister<StakingFlowBloc>();
    get.unregister<ProposalsBloc>();

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
    final bloc = StakingFlowBloc(account: widget.account);
    get.registerSingleton<StakingFlowBloc>(bloc);
    bloc.load();
    final gBloc = ProposalsBloc(account: widget.account);
    get.registerSingleton<ProposalsBloc>(gBloc);
    gBloc.load();

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
                children: [
                  StakingTab(),
                  ProposalsFlow(account: widget.account),
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
