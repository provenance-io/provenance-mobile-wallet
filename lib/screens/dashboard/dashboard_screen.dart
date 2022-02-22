import 'package:grpc/grpc.dart';
import 'package:provenance_wallet/common/models/asset.dart';
import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/landing/dashboard_landing_tab.dart';
import 'package:provenance_wallet/screens/dashboard/tab_item.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/transaction_landing.dart';
import 'package:provenance_wallet/screens/dashboard/my_account.dart';
import 'package:provenance_wallet/screens/transaction/transaction_confirm_screen.dart';
import 'package:provenance_wallet/services/wallet_connect_tx_response.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/services/remote_client_details.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/services/requests/sign_request.dart';
import 'package:provenance_wallet/services/wallet_service.dart';
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
  String _walletAddress = '';
  String _walletName = '';
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
  void didPopNext() {
    loadAddress();
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    RouterObserver.instance.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    if (!_initialLoad) {
      this.loadAssets();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _bloc.sendRequest.listen(_onSendRequest).addTo(_subscriptions);
    _bloc.signRequest.listen(_onSignRequest).addTo(_subscriptions);
    _bloc.sessionRequest.listen(_onSessionRequest).addTo(_subscriptions);
    _bloc.error.listen(_onError).addTo(_subscriptions);
    _bloc.response.listen(_onResponse).addTo(_subscriptions);

    get.registerSingleton<DashboardBloc>(_bloc);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_setCurrentTab);
    WidgetsBinding.instance?.addObserver(this);

    loadAddress();

    super.initState();
  }

  void loadAddress() async {
    final wallet = await get<WalletService>().getSelectedWallet();
    if (wallet == null) {
      logError('Failed to load selected wallet');

      return;
    }
    setState(() {
      _walletAddress = wallet.address;
      _walletName = wallet.name;
    });
    this.loadAssets();
  }

  void loadAssets() async {
    ModalLoadingRoute.showLoading(Strings.loadingAssets, context);
    _bloc.load(_walletAddress);
    ModalLoadingRoute.dismiss(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.provenanceNeutral800,
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
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  DashboardLandingTab(
                    walletName: _walletName,
                  ),
                  TransactionLanding(
                    walletAddress: _walletAddress,
                    walletName: _walletName,
                  ),
                  MyAccount(),
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
    final allowed =
        await PwDialog.showSessionConfirmation(context, remoteClientDetails);

    await get<DashboardBloc>().approveSession(
      requestId: remoteClientDetails.id,
      allowed: allowed,
    );
  }

  Future<void> _onSendRequest(SendRequest sendRequest) async {
    final screen = TransactionConfirmScreen(
      request: sendRequest,
    );

    final approved = await Navigator.of(context).push(screen.route());

    await get<DashboardBloc>().sendMessageFinish(
      requestId: sendRequest.id,
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
      PwDialog.showMessage(
        context,
        title: Strings.transactionSuccessTitle,
        message: response.message ?? '',
      );
    } else {
      PwDialog.showError(
        context,
        message: response.message ?? '',
      );
    }
  }
}
