import 'dart:async';

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal/pw_modal_screen.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/home/asset/dashboard_tab.dart';
import 'package:provenance_wallet/screens/home/asset/dashboard_tab_bloc.dart';
import 'package:provenance_wallet/screens/home/dashboard/transactions_bloc.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/home/tab_item.dart';
import 'package:provenance_wallet/screens/home/transactions/transaction_tab.dart';
import 'package:provenance_wallet/screens/home/view_more/view_more_tab.dart';
import 'package:provenance_wallet/screens/transaction/transaction_confirm_screen.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/session_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/messages/message_field_name.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  late TabController _tabController;
  int _currentTabIndex = 0;

  final _subscriptions = CompositeSubscription();
  CompositeSubscription _providerSubscriptions = CompositeSubscription();

  final _walletConnectService = get<WalletConnectService>();
  final _txQueueService = get<TxQueueService>();

  List<Asset> assets = [];
  List<Transaction> transactions = [];

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    RouterObserver.instance.routeObserver.unsubscribe(this);
    _tabController.removeListener(_setCurrentTab);
    _tabController.dispose();
    _subscriptions.dispose();
    _providerSubscriptions.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    RouterObserver.instance.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);

    final bloc = Provider.of<HomeBloc>(context);
    _providerSubscriptions.cancel();
    final providerSubscriptions = CompositeSubscription();
    bloc.isLoading.listen((e) {
      if (e) {
        ModalLoadingRoute.showLoading(context);
      } else {
        ModalLoadingRoute.dismiss(context);
      }
    }).addTo(providerSubscriptions);
    bloc.error.listen(_onError).addTo(providerSubscriptions);
    _providerSubscriptions = providerSubscriptions;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _walletConnectService.delegateEvents.sessionRequest
        .listen(_onSessionRequest)
        .addTo(_subscriptions);

    _walletConnectService.sessionEvents.error
        .listen(_onError)
        .addTo(_subscriptions);
    _walletConnectService.delegateEvents.onDidError
        .listen(_onError)
        .addTo(_subscriptions);

    _txQueueService.response.listen(_onResponse).addTo(_subscriptions);

    _walletConnectService.delegateEvents.onResponse
        .listen(_onResponse)
        .addTo(_subscriptions);

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
      body: Provider<DashboardTabBloc>(
        lazy: true,
        create: (context) {
          return DashboardTabBloc();
        },
        dispose: (_, bloc) {
          bloc.onDispose();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Provider<TransactionsBloc>(
                create: (context) {
                  final _bloc = TransactionsBloc(
                    allMessageTypes: strings.dropDownAllMessageTypes,
                    allStatuses: strings.dropDownAllStatuses,
                  )..load();
                  return _bloc;
                },
                dispose: (context, bloc) {
                  bloc.onDispose();
                },
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
    SessionAction details,
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

  void _onResponse(TxResult result) {
    final clientDetails =
        _walletConnectService.sessionEvents.state.valueOrNull?.details;

    const statusCodeOk = 0;

    final txResponse = result.response.txResponse;

    final title = txResponse.code == statusCodeOk
        ? Strings.of(context).transactionSuccessTitle
        : Strings.of(context).transactionErrorTitle;

    final data = <String, dynamic>{};
    if (result.body.messages.isNotEmpty) {
      // TODO-Roy: Show the type of all messages, not just the first.
      data[MessageFieldName.type] =
          result.body.messages.first.info_.qualifiedMessageName;
    }

    data.addAll(
      {
        FieldName.gasWanted: txResponse.gasWanted.toString(),
        FieldName.gasUsed: txResponse.gasUsed.toString(),
        FieldName.txID: txResponse.txhash,
        FieldName.block: txResponse.height.toString(),
      },
    );

    if (txResponse.code != statusCodeOk) {
      data.addAll(
        {
          FieldName.gasWanted: txResponse.gasWanted.toString(),
          FieldName.gasUsed: txResponse.gasUsed.toString(),
          FieldName.txID: txResponse.txhash,
          FieldName.block: txResponse.height.toString(),
          FieldName.code: txResponse.code,
          FieldName.codespace: txResponse.codespace,
          FieldName.rawLog: txResponse.rawLog,
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
          clientMeta: clientDetails,
          data: [
            data,
          ],
          fees: result.fee.amount,
        );
      },
    );
  }
}
