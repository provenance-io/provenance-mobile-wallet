import 'dart:async';

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal/pw_modal_screen.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/home/asset/dashboard_tab.dart';
import 'package:provenance_wallet/screens/home/asset/dashboard_tab_bloc.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/home/tab_item.dart';
import 'package:provenance_wallet/screens/home/transactions/transaction_tab.dart';
import 'package:provenance_wallet/screens/home/view_more/view_more_tab.dart';
import 'package:provenance_wallet/screens/transaction/transaction_confirm_screen.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/services/models/wallet_connect_tx_response.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/messages/message_field_name.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class HomeScreen extends StatefulWidget {
  final String allMessageTypes;
  final String allStatuses;
  const HomeScreen({
    Key? key,
    required this.allMessageTypes,
    required this.allStatuses,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  late TabController _tabController;
  int _currentTabIndex = 0;

  final _subscriptions = CompositeSubscription();

  late final _bloc = HomeBloc(
    allMessageTypes: widget.allMessageTypes,
    allStatuses: widget.allStatuses,
  );
  final _walletConnectService = get<WalletConnectService>();

  List<Asset> assets = [];
  List<Transaction> transactions = [];

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    RouterObserver.instance.routeObserver.unsubscribe(this);
    _tabController.removeListener(_setCurrentTab);
    _tabController.dispose();
    _subscriptions.dispose();

    get.unregister<HomeBloc>();
    if (get.isRegistered<DashboardTabBloc>()) {
      get.unregister<DashboardTabBloc>();
    }

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
    _bloc.isLoading.listen((e) {
      if (e) {
        ModalLoadingRoute.showLoading(context);
      } else {
        ModalLoadingRoute.dismiss(context);
      }
    }).addTo(_subscriptions);
    _walletConnectService.delegateEvents.sessionRequest
        .listen(_onSessionRequest)
        .addTo(_subscriptions);

    _walletConnectService.sessionEvents.error
        .listen(_onError)
        .addTo(_subscriptions);
    _walletConnectService.delegateEvents.onDidError
        .listen(_onError)
        .addTo(_subscriptions);
    _bloc.error.listen(_onError).addTo(_subscriptions);
    _walletConnectService.delegateEvents.onResponse
        .listen(_onResponse)
        .addTo(_subscriptions);

    get.registerSingleton<HomeBloc>(_bloc);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_setCurrentTab);
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
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
                  strings.dashboard,
                  PwIcons.dashboard,
                  topPadding: topPadding,
                  bottomPadding: bottomPadding,
                ),
                TabItem(
                  1 == _currentTabIndex,
                  strings.transactions,
                  PwIcons.staking,
                  topPadding: topPadding,
                  bottomPadding: bottomPadding,
                ),
                TabItem(
                  2 == _currentTabIndex,
                  strings.homeScreenMore,
                  PwIcons.viewMore,
                  topPadding: topPadding,
                  bottomPadding: bottomPadding,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                DashboardTab(),
                TransactionTab(),
                ViewMoreTab(
                  onFlowCompletion: () {
                    setState(() {
                      _tabController.animateTo(0);
                      _currentTabIndex = 0;
                    });
                  },
                ),
              ],
            ),
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

  Future<void> _onSessionRequest(
    WalletConnectSessionRequestData details,
  ) async {
    final strings = Strings.of(context);
    final name = details.data.clientMeta.name;
    final allowed = await PwModalScreen.showConfirm(
      context: context,
      approveText: strings.sessionApprove,
      declineText: strings.sessionReject,
      title: strings.dashboardConnectionRequestTitle,
      message:
          Strings.of(context).dashboardConnectionRequestAllowConnectionTo(name),
      icon: Image.asset(
        Assets.imagePaths.connectionRequest,
      ),
    );

    await get<WalletConnectService>().approveSession(
      details: details,
      allowed: allowed,
    );
  }

  void _onError(String message) {
    logError(message);
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (context) => ErrorDialog(
        title: Strings.of(context).serviceErrorTitle,
        error: message,
        buttonText: Strings.of(context).continueName,
      ),
    );
  }

  void _onResponse(WalletConnectTxResponse response) {
    final clientDetails =
        _walletConnectService.sessionEvents.state.value.details;
    if (clientDetails == null) {
      _onError(Strings.of(context).errorDisconnected);

      return;
    }

    const statusCodeOk = 0;

    final title = response.code == statusCodeOk
        ? Strings.of(context).transactionSuccessTitle
        : Strings.of(context).transactionErrorTitle;

    final data = <String, dynamic>{};
    if (response.tx?.body.messages.isNotEmpty ?? false) {
      data[MessageFieldName.type] =
          response.tx?.body.messages.first.info_.qualifiedMessageName;
    }

    data.addAll(
      {
        FieldName.gasWanted: response.gasWanted.toString(),
        FieldName.gasUsed: response.gasUsed.toString(),
        FieldName.txID: response.txHash,
        FieldName.block: response.height?.toString(),
      },
    );

    if (response.code != statusCodeOk) {
      data.addAll(
        {
          FieldName.gasWanted: response.gasWanted.toString(),
          FieldName.gasUsed: response.gasUsed.toString(),
          FieldName.txID: response.txHash,
          FieldName.block: response.height?.toString(),
          FieldName.code: response.code,
          FieldName.codespace: response.codespace,
          FieldName.rawLog: response.message,
        },
      );
    }

    showGeneralDialog(
      context: (context),
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return TransactionConfirmScreen(
          kind: TransactionConfirmKind.notify,
          title: title,
          requestId: response.requestId,
          clientMeta: clientDetails,
          data: [
            data,
          ],
          fees: response.fees,
        );
      },
    );
  }
}
