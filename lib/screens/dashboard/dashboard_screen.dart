import 'package:grpc/grpc.dart';
import 'package:provenance_wallet/common/models/asset.dart';
import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal/pw_modal_screen.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/landing/dashboard_landing_tab.dart';
import 'package:provenance_wallet/screens/dashboard/tab_item.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/transaction_landing_tab.dart';
import 'package:provenance_wallet/screens/dashboard/profile/profile_screen.dart';
import 'package:provenance_wallet/screens/transaction/transaction_confirm_screen.dart';
import 'package:provenance_wallet/services/wallet_connect_transaction_request.dart';
import 'package:provenance_wallet/services/wallet_connect_tx_response.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/services/remote_client_details.dart';
import 'package:provenance_wallet/services/requests/sign_request.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  late TabController _tabController;
  bool _initialLoad = false;
  int _currentTabIndex = 0;

  final _subscriptions = CompositeSubscription();
  final _bloc = DashboardBloc();

  List<Asset> assets = [];
  List<Transaction> transactions = [];

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    RouterObserver.instance.routeObserver.unsubscribe(this);
    _tabController.removeListener(_setCurrentTab);
    _tabController.dispose();
    _subscriptions.dispose();

    get.unregister<DashboardBloc>();

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
    _bloc.transactionRequest
        .listen(_onTransactionRequest)
        .addTo(_subscriptions);
    _bloc.signRequest.listen(_onSignRequest).addTo(_subscriptions);
    _bloc.sessionRequest.listen(_onSessionRequest).addTo(_subscriptions);
    _bloc.error.listen(_onError).addTo(_subscriptions);
    _bloc.response.listen(_onResponse).addTo(_subscriptions);

    get.registerSingleton<DashboardBloc>(_bloc);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_setCurrentTab);
    WidgetsBinding.instance?.addObserver(this);

    _bloc.load();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.neutral800,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VerticalSpacer.large(),
            Container(
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.transparent,
                tabs: [
                  TabItem(
                    0 == _currentTabIndex,
                    Strings.dashboard,
                    PwIcons.dashboard,
                  ),
                  TabItem(
                    1 == _currentTabIndex,
                    Strings.transactions,
                    PwIcons.staking,
                  ),
                  TabItem(
                    2 == _currentTabIndex,
                    Strings.profile,
                    PwIcons.userAccount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.images.background),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: const [
                  DashboardLandingTab(),
                  TransactionLandingTab(),
                  ProfileScreen(),
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

  Future<void> _onSessionRequest(
    RemoteClientDetails remoteClientDetails,
  ) async {
    final name = remoteClientDetails.name;
    final allowed = await PwModalScreen.showConfirm(
      context: context,
      approveText: Strings.sessionApprove,
      declineText: Strings.sessionReject,
      title: Strings.dashboardConnectionRequestTitle,
      message: Strings.dashboardConnectionRequestDetails(name),
      icon: Image.asset(
        AssetPaths.images.connectionRequest,
      ),
    );

    await get<DashboardBloc>().approveSession(
      details: remoteClientDetails,
      allowed: allowed,
    );
  }

  Future<void> _onTransactionRequest(
    WalletConnectTransactionRequest transactionRequest,
  ) async {
    final approved = await showGeneralDialog<bool?>(
      context: context,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return TransactionConfirmScreen(
          request: transactionRequest,
        );
      },
    );

    await get<DashboardBloc>().sendMessageFinish(
      requestId: transactionRequest.details.id,
      allowed: approved ?? false,
    );
  }

  Future<void> _onSignRequest(SignRequest signRequest) async {
    final allowed = await PwDialog.showConfirmation(
      context,
      title: signRequest.description,
      message: signRequest.message,
      confirmText: Strings.sign,
      cancelText: Strings.decline,
    );
    ModalLoadingRoute.showLoading("", context);

    await get<DashboardBloc>().signTransactionFinish(
      requestId: signRequest.id,
      allowed: allowed,
    );

    ModalLoadingRoute.dismiss(context);
  }

  void _onError(String message) {
    logError(message);
    PwDialog.showError(
      context,
      message: message,
    );
  }

  void _onResponse(WalletConnectTxResponse response) {
    if (response.code == StatusCode.ok) {
      PwModalScreen.showNotify(
        context: context,
        title: Strings.transactionComplete,
        icon: Image.asset(
          AssetPaths.images.transactionComplete,
          width: 80,
        ),
        buttonText: Strings.transactionBackToDashboard,
      );
    } else {
      PwDialog.showError(
        context,
        message: response.message ?? '',
      );
    }
  }
}
