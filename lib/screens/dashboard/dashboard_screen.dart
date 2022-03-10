import 'dart:async';

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal/pw_modal_screen.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_chart_screen.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/landing/dashboard_landing_tab.dart';
import 'package:provenance_wallet/screens/dashboard/profile/profile_screen.dart';
import 'package:provenance_wallet/screens/dashboard/tab_item.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/transaction_landing_tab.dart';
import 'package:provenance_wallet/screens/transaction/transaction_confirm_screen.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/requests/send_request.dart';
import 'package:provenance_wallet/services/models/requests/sign_request.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/services/models/wallet_connect_tx_response.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/messages/message_field_name.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  late TabController _tabController;
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
    _bloc.delegateEvents.sendRequest
        .listen(_onSendRequest)
        .addTo(_subscriptions);
    _bloc.delegateEvents.signRequest
        .listen(_onSignRequest)
        .addTo(_subscriptions);
    _bloc.delegateEvents.sessionRequest
        .listen(_onSessionRequest)
        .addTo(_subscriptions);
    _bloc.sessionEvents.error.listen(_onError).addTo(_subscriptions);
    _bloc.delegateEvents.onDidError.listen(_onError).addTo(_subscriptions);
    _bloc.error.listen(_onError).addTo(_subscriptions);
    _bloc.delegateEvents.onResponse.listen(_onResponse).addTo(_subscriptions);

    get.registerSingleton<DashboardBloc>(_bloc);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_setCurrentTab);
    WidgetsBinding.instance?.addObserver(this);

    _bloc.load(tabController: _tabController);

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
            TabBar(
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
                StreamBuilder<Asset?>(
                  initialData: _bloc.selectedAsset.value,
                  stream: _bloc.selectedAsset,
                  builder: (context, snapshot) {
                    final asset = snapshot.data;

                    return null == asset
                        ? DashboardLandingTab()
                        : AssetChartScreen();
                  },
                ),
                TransactionLandingTab(),
                ProfileScreen(),
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
        AssetPaths.images.connectionRequest,
      ),
    );

    await get<DashboardBloc>().approveSession(
      details: details,
      allowed: allowed,
    );
  }

  Future<void> _onSendRequest(
    SendRequest sendRequest,
  ) async {
    final clientDetails = _bloc.sessionEvents.state.value.details;
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

    ModalLoadingRoute.showLoading("", context);

    await get<DashboardBloc>()
        .sendMessageFinish(
          requestId: sendRequest.id,
          allowed: approved ?? false,
        )
        .whenComplete(() => ModalLoadingRoute.dismiss(context));
  }

  Future<void> _onSignRequest(SignRequest signRequest) async {
    final clientDetails = _bloc.sessionEvents.state.value.details;
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

    ModalLoadingRoute.showLoading("", context);

    await get<DashboardBloc>()
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
    final clientDetails = _bloc.sessionEvents.state.value.details;
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
