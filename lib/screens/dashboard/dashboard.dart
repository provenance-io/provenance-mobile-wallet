import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/fw_dialog.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/network/models/asset_response.dart';
import 'package:provenance_wallet/network/models/transaction_response.dart';
import 'package:provenance_wallet/network/services/asset_service.dart';
import 'package:provenance_wallet/network/services/transaction_service.dart';
import 'package:provenance_wallet/screens/dashboard/tab_item.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/transaction_landing.dart';
import 'package:provenance_wallet/screens/dashboard/landing/wallet_portfolio.dart';
import 'package:provenance_wallet/screens/dashboard/my_account.dart';
import 'package:provenance_wallet/screens/dashboard/wallets.dart';
import 'package:provenance_wallet/screens/send_transaction_approval.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/util/router_observer.dart';

import 'landing/dashboard_landing.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DashboardState();
}

class DashboardState extends State<Dashboard>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  late TabController _tabController;
  String _walletAddress = '';
  String _walletName = '';
  String _walletValue = '';
  bool _initialLoad = false;
  int _currentTabIndex = 0;
  // FIXME: State Management
  GlobalKey<WalletPortfolioState> _walletKey = GlobalKey();
  GlobalKey<DashboardLandingState> _landingKey = GlobalKey();
  GlobalKey<TransactionLandingState> _transactionKey = GlobalKey();

  List<AssetResponse> assets = [];
  List<TransactionResponse> transactions = [];

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    RouterObserver.instance.routeObserver.unsubscribe(this);
    _tabController.removeListener(_setCurrentTab);
    _tabController.dispose();
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
  void didUpdateWidget(covariant Dashboard oldWidget) {
    if (!_initialLoad) {
      this.loadAssets();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_setCurrentTab);
    WidgetsBinding.instance?.addObserver(this);
    ProvWalletFlutter.instance.onAskToSign = (
      String requestId,
      String message,
      String description,
    ) async {
      final result = await FwDialog.showConfirmation(
        context,
        title: description,
        message: message,
        confirmText: Strings.sign,
        cancelText: Strings.decline,
      );
      ModalLoadingRoute.showLoading("", context);
      await ProvWalletFlutter.signTransactionFinish(requestId, result);
      ModalLoadingRoute.dismiss(context);
    };

    ProvWalletFlutter.instance.onAskToSend = (
      String requestId,
      TransactionMessage message,
      String description,
      String cost,
    ) {
      SendTransactionInfo info = SendTransactionInfo(
        fee: cost,
        toAddress: message.toAddress ?? '',
        fromAddress: message.fromAddress ?? '',
        requestId: requestId,
        amount: message.displayAmount,
      );
      Navigator.of(context).push(SendTransactionApproval(info).route());
    };

    ProvWalletFlutter.configureServer();
    loadAddress();
    super.initState();
  }

  void loadAddress() async {
    final details = await ProvWalletFlutter.getWalletDetails();
    setState(() {
      _walletAddress = details.address;
      _walletName = details.accountName;
      _walletValue = '\$0';
      _walletKey.currentState?.updateValue(_walletValue);
    });
    this.loadAssets();
  }

  void loadAssets() async {
    ModalLoadingRoute.showLoading(Strings.loadingAssets, context);

    //final result = await AssetService.getAssets(_walletAddress);
    final result = await AssetService.getFakeAssets(_walletAddress);
    final transactions =
        await TransactionService.getFakeTransactions(_walletAddress);
    ModalLoadingRoute.dismiss(context);
    //if (result.isSuccessful) {
    setState(() {
      this.assets = result;
      this.transactions = transactions;
      // FIXME: State Management
      _landingKey.currentState?.updateAssets(result);
      _transactionKey.currentState?.updateTransactions(transactions);
      _initialLoad = false;
    });
    // } else {
    //   setState(() {
    //     // FIXME: State Management
    //     _landingKey.currentState?.updateAssets([]);
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 0.0,
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: 24,
              top: 10,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(Wallets().route());
              },
              child: FwIcon(
                FwIcons.wallet,
                color: Theme.of(context).colorScheme.globalNeutral450,
                size: 24.0,
              ),
            ),
          ),
        ],
        title: Padding(
          padding: EdgeInsets.only(
            top: 20,
          ),
          child: FwText(
            _currentTabIndex == 0 ? _walletName : Strings.transactionDetails,
            style: FwTextStyle.h6,
            color: FwColor.globalNeutral550,
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(
            left: 24,
            top: 10,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MyAccount().route());
            },
            child: FwIcon(
              FwIcons.userAccount,
              color: Theme.of(context).colorScheme.globalNeutral450,
              size: 24.0,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 2,
            color: Theme.of(context).colorScheme.globalNeutral250,
          ),
          Container(
            color: Theme.of(context).colorScheme.globalNeutral50,
            // height: 50 + inset?.bottom ?? 0,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.transparent,
              tabs: [
                TabItem(
                  0 == _currentTabIndex,
                  Strings.dashboard,
                  FwIcons.wallet,
                ),
                TabItem(
                  1 == _currentTabIndex,
                  Strings.transactions,
                  FwIcons.staking,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _walletAddress.isNotEmpty && _currentTabIndex == 0
              ? Container(
                  color: Theme.of(context).colorScheme.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FwText(
                        '${_walletAddress.substring(0, 3)}...${_walletAddress.substring(36)}',
                        color: FwColor.globalNeutral400,
                        style: FwTextStyle.m,
                      ),
                      HorizontalSpacer.small(),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: _walletAddress),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: FwText(Strings.addressCopied)),
                          );
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          child: FwIcon(
                            FwIcons.copy,
                            color:
                                Theme.of(context).colorScheme.globalNeutral400,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                DashboardLanding(
                  // FIXME: State Management
                  key: _landingKey,
                  walletKey: _walletKey,
                ),
                TransactionLanding(
                  // FIXME: State Management
                  key: _transactionKey,
                  walletAddress: _walletAddress,
                  walletName: _walletName,
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
      _walletKey.currentState?.updateValue(_walletValue);
      _landingKey.currentState?.updateAssets(assets);
      _transactionKey.currentState?.updateTransactions(transactions);
    });
  }
}
