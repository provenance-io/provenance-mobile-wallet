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
import 'package:provenance_wallet/services/models/requests/send_request.dart';
import 'package:provenance_wallet/services/models/requests/sign_request.dart';
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

  final _bloc = HomeBloc();
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
    _walletConnectService.delegateEvents.sendRequest
        .listen(_onSendRequest)
        .addTo(_subscriptions);
    _walletConnectService.delegateEvents.signRequest
        .listen(_onSignRequest)
        .addTo(_subscriptions);
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
                  Strings.dashboard,
                  PwIcons.dashboard,
                  topPadding: topPadding,
                  bottomPadding: bottomPadding,
                ),
                TabItem(
                  1 == _currentTabIndex,
                  Strings.transactions,
                  PwIcons.staking,
                  topPadding: topPadding,
                  bottomPadding: bottomPadding,
                ),
                TabItem(
                  2 == _currentTabIndex,
                  Strings.viewMore,
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
    final name = details.data.clientMeta.name;
    final allowed = await PwModalScreen.showConfirm(
      context: context,
      approveText: Strings.sessionApprove,
      declineText: Strings.sessionReject,
      title: Strings.dashboardConnectionRequestTitle,
      message: Strings.dashboardConnectionRequestDetails(name),
      icon: Image.asset(
        Assets.imagePaths.connectionRequest,
      ),
    );

    await get<WalletConnectService>().approveSession(
      details: details,
      allowed: allowed,
    );
  }

  Future<void> _onSendRequest(
    SendRequest sendRequest,
  ) async {
    final clientDetails =
        _walletConnectService.sessionEvents.state.value.details;
    if (clientDetails == null) {
      _onError(Strings.errorDisconnected);

      return;
    }

    final approved = await showGeneralDialog<bool?>(
      context: context,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        final messages = sendRequest.messages;
        final data = messages.map((message) {
          return <String, dynamic>{
            MessageFieldName.type: message.info_.qualifiedMessageName,
            ...message.toProto3Json() as Map<String, dynamic>,
          };
        }).toList();

        return TransactionConfirmScreen(
          kind: TransactionConfirmKind.approve,
          title: Strings.confirmTransactionTitle,
          requestId: sendRequest.id,
          clientMeta: clientDetails,
          data: data,
          fees: sendRequest.gasEstimate.feeCalculated,
        );
      },
    );

    ModalLoadingRoute.showLoading(context);

    await get<WalletConnectService>()
        .sendMessageFinish(
          requestId: sendRequest.id,
          allowed: approved ?? false,
        )
        .whenComplete(() => ModalLoadingRoute.dismiss(context));
  }

  Future<void> _onSignRequest(SignRequest signRequest) async {
    final clientDetails =
        _walletConnectService.sessionEvents.state.value.details;
    if (clientDetails == null) {
      _onError(Strings.errorDisconnected);

      return;
    }

    final approved = await showGeneralDialog<bool>(
      context: context,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return TransactionConfirmScreen(
          kind: TransactionConfirmKind.approve,
          title: Strings.confirmSignTitle,
          requestId: signRequest.id,
          subTitle: signRequest.description,
          clientMeta: clientDetails,
          message: signRequest.message,
          data: [
            {
              MessageFieldName.address: signRequest.address,
            },
          ],
        );
      },
    );

    ModalLoadingRoute.showLoading(context);

    await get<WalletConnectService>()
        .signTransactionFinish(
          requestId: signRequest.id,
          allowed: approved ?? false,
        )
        .whenComplete(() => ModalLoadingRoute.dismiss(context));
  }

  void _onError(String message) {
    logError(message);
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (context) => ErrorDialog(
        title: Strings.serviceErrorTitle,
        error: message,
        buttonText: Strings.continueName,
      ),
    );
  }

  void _onResponse(WalletConnectTxResponse response) {
    final clientDetails =
        _walletConnectService.sessionEvents.state.value.details;
    if (clientDetails == null) {
      _onError(Strings.errorDisconnected);

      return;
    }

    const statusCodeOk = 0;

    final title = response.code == statusCodeOk
        ? Strings.transactionSuccessTitle
        : Strings.transactionErrorTitle;

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
