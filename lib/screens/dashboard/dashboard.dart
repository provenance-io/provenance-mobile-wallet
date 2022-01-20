import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/fw_dialog.dart';
import 'package:flutter_tech_wallet/common/widgets/modal_loading.dart';
import 'package:flutter_tech_wallet/network/models/asset_response.dart';
import 'package:flutter_tech_wallet/network/services/asset_service.dart';
import 'package:flutter_tech_wallet/screens/dashboard/wallets.dart';
import 'package:flutter_tech_wallet/screens/send_transaction_approval.dart';
import 'package:flutter_tech_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:flutter_tech_wallet/util/router_observer.dart';

import 'dashboard_landing.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DashboardState();
}

class DashboardState extends State<Dashboard>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  TabController? _tabController;
  String _walletAddress = '';
  String _walletName = '';
  String _walletValue = '';
  bool _assetsLoading = true;

  List<AssetResponse> assets = [];

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    RouterObserver.instance.routeObserver.unsubscribe(this);
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
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
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
      String message,
      String description,
      String cost,
    ) {
      final map = jsonDecode(message);

      SendTransactionInfo info = SendTransactionInfo(
        fee: cost,
        toAddress: map["toAddress"] as String,
        fromAddress: map["fromAddress"] as String,
        requestId: requestId,
        amount:
            "${(map["amount"] as List).first["amount"]} ${(map["amount"] as List).first["denom"]}",
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
    });

    ModalLoadingRoute.showLoading(Strings.loadingAssets, context);

    final result = await AssetService.getAssets(_walletAddress);

    ModalLoadingRoute.dismiss(context);
    if (result.isSuccessful) {
      setState(() {
        assets = result.data ?? [];
      });
    } else {
      setState(() {
        assets = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            _walletName,
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
            onTap: () {},
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
                _buildTabItem(
                  _tabController?.index == 0,
                  Strings.dashboard,
                  FwIcons.wallet,
                ),
                _buildTabItem(
                  _tabController?.index == 1,
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
          _walletAddress.isEmpty
              ? Container()
              : Container(
                  color: Colors.white,
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
                ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                DashboardLanding(
                  assets: assets,
                  walletValue: _walletValue,
                ),
                Container(color: Colors.white, child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    bool isSelected,
    String tabName,
    String tabAsset, {
    isLoading = false,
  }) {
    var color = isSelected
        ? Theme.of(context).colorScheme.primary7
        : Theme.of(context).colorScheme.globalNeutral350;

    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 24.0,
            height: 24.0,
            child: isLoading == null || !isLoading
                ? FwIcon(
                    tabAsset,
                    color: color,
                  )
                : const CircularProgressIndicator(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 28),
            child: Text(
              tabName,
              style: Theme.of(context)
                  .textTheme
                  .extraSmallBold
                  .copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
