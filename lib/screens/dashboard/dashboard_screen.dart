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
import 'package:provenance_wallet/screens/dashboard/wallets.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/screens/send_transaction_approval.dart';
import 'package:provenance_wallet/services/wallet_connection_service_status.dart';
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
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AssetPaths.images.background),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          StreamBuilder<WalletConnectionServiceStatus>(
            initialData: _bloc.connectionStatus.value,
            stream: _bloc.connectionStatus,
            builder: (context, snapshot) {
              final connected =
                  snapshot.data == WalletConnectionServiceStatus.connected;

              return Padding(
                padding: EdgeInsets.only(
                  right: Spacing.xxLarge,
                ),
                child: GestureDetector(
                  onTap: () async {
                    if (connected) {
                      _bloc.disconnectWallet();
                    }
                    final addressData = await Navigator.of(
                      context,
                    ).push(
                      QRCodeScanner().route<String?>(),
                    );
                    if (addressData != null) {
                      _bloc.connectWallet(addressData);
                    }
                  },
                  child: PwIcon(
                    PwIcons.qr,
                    color: Theme.of(context).colorScheme.white,
                    size: 48.0,
                  ),
                ),
              );
            },
          ),
        ],
        centerTitle: false,
        title: PwText(
          _currentTabIndex == 0 ? _walletName : Strings.transactionDetails,
          style: PwTextStyle.subhead,
        ),
        leading: Padding(
          padding: EdgeInsets.only(
            left: Spacing.large,
            top: 18,
            bottom: 18,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(Wallets().route());
            },
            child: PwIcon(
              PwIcons.ellipsis,
              color: Theme.of(context).colorScheme.white,
              size: 20,
            ),
          ),
        ),
      ),
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
            // _walletAddress.isNotEmpty && _currentTabIndex == 0
            //     ? Container(
            //         color: Theme.of(context).colorScheme.provenanceNeutral800,
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             PwText(
            //               '${_walletAddress.substring(0, 3)}...${_walletAddress.substring(36)}',
            //               color: PwColor.globalNeutral400,
            //               style: PwTextStyle.m,
            //             ),
            //             HorizontalSpacer.small(),
            //             GestureDetector(
            //               onTap: () {
            //                 Clipboard.setData(
            //                   ClipboardData(text: _walletAddress),
            //                 );
            //                 ScaffoldMessenger.of(context).showSnackBar(
            //                   SnackBar(content: PwText(Strings.addressCopied)),
            //                 );
            //               },
            //               child: Container(
            //                 width: 24,
            //                 height: 24,
            //                 child: PwIcon(
            //                   PwIcons.copy,
            //                   color: Theme.of(context)
            //                       .colorScheme
            //                       .globalNeutral400,
            //                   size: 24,
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       )
            //     : Container(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  DashboardLandingTab(),
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
    SendTransactionInfo info = SendTransactionInfo(
      fee: sendRequest.cost,
      toAddress: sendRequest.message.toAddress ?? '',
      fromAddress: sendRequest.message.fromAddress ?? '',
      requestId: sendRequest.id,
      amount: sendRequest.message.displayAmount,
    );

    final approved =
        await Navigator.of(context).push(SendTransactionApproval(info).route());

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
}
