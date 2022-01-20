import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/button.dart';
import 'package:flutter_tech_wallet/common/widgets/fw_dialog.dart';
import 'package:flutter_tech_wallet/common/widgets/modal_loading.dart';
import 'package:flutter_tech_wallet/network/models/asset_response.dart';
import 'package:flutter_tech_wallet/network/services/asset_service.dart';
import 'package:flutter_tech_wallet/screens/dashboard/my_account.dart';
import 'package:flutter_tech_wallet/screens/dashboard/wallets.dart';
import 'package:flutter_tech_wallet/screens/landing/landing.dart';
import 'package:flutter_tech_wallet/screens/qr_code_scanner.dart';
import 'package:flutter_tech_wallet/screens/send_transaction_approval.dart';
import 'package:flutter_tech_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:flutter_tech_wallet/util/router_observer.dart';

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
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(Wallets().route());
            },
            child: FwIcon(
              FwIcons.wallet,
              color: Theme.of(context).colorScheme.globalNeutral450,
              size: 24,
            ),
          ),
          HorizontalSpacer.medium(),
        ],
        title: FwText(
          _walletName,
          style: FwTextStyle.h6,
          color: FwColor.globalNeutral550,
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: 24),
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
            color: Theme.of(context).colorScheme.globalNeutral550,
          ),
          Container(
            color: Theme.of(context).colorScheme.globalNeutral600Black,
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .globalNeutral600Black,
                              borderRadius: BorderRadius.circular(11.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: 17, right: 17),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 24,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      FwText(
                                        Strings.portfolioValue,
                                        color: FwColor.white,
                                        style: FwTextStyle.sBold,
                                      ),
                                      FwText(
                                        _walletValue,
                                        color: FwColor.white,
                                        style: FwTextStyle.h6,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 17,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 100,
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .globalNeutral450,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    23,
                                                  ),
                                                ),
                                                height: 46,
                                                width: 46,
                                                child: Center(
                                                  child: FwIcon(
                                                    FwIcons.upArrow,
                                                    size: 24,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              VerticalSpacer.xSmall(),
                                              FwText(
                                                Strings.send,
                                                color: FwColor.white,
                                                style: FwTextStyle.s,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 100,
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .globalNeutral450,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    23,
                                                  ),
                                                ),
                                                height: 46,
                                                width: 46,
                                                child: Center(
                                                  child: FwIcon(
                                                    FwIcons.downArrow,
                                                    size: 24,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              VerticalSpacer.xSmall(),
                                              FwText(
                                                Strings.receive,
                                                color: FwColor.white,
                                                style: FwTextStyle.s,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      StreamBuilder<WallectConnectStatus>(
                                        stream: ProvWalletFlutter.instance
                                            .walletConnectStatus.stream,
                                        initialData:
                                            WallectConnectStatus.disconnected,
                                        builder: (context, snapshot) {
                                          if (snapshot == null ||
                                              snapshot.data == null) {
                                            return Container(
                                              width: 100,
                                            );
                                          }

                                          if (snapshot.data ==
                                              WallectConnectStatus
                                                  .disconnected) {
                                            return Container(
                                              width: 100,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  final result =
                                                      await Navigator.of(
                                                    context,
                                                  ).push(
                                                    QRCodeScanner().route(),
                                                  );
                                                  ProvWalletFlutter
                                                      .connectWallet(
                                                    result as String,
                                                  );
                                                },
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(
                                                          context,
                                                        )
                                                            .colorScheme
                                                            .globalNeutral450,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(23),
                                                      ),
                                                      height: 46,
                                                      width: 46,
                                                      child: Center(
                                                        child: FwIcon(
                                                          FwIcons.walletConnect,
                                                          size: 15,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    VerticalSpacer.xSmall(),
                                                    FwText(
                                                      Strings.walletConnect,
                                                      color: FwColor.white,
                                                      style: FwTextStyle.s,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }

                                          return Container(
                                            width: 100,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        assets.isNotEmpty
                            ? VerticalSpacer.medium()
                            : Container(),
                        assets.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    FwText(
                                      Strings.myAssets,
                                      color: FwColor.globalNeutral550,
                                      style: FwTextStyle.h6,
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        assets.isNotEmpty
                            ? VerticalSpacer.medium()
                            : Container(),
                        assets.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    final item = assets[index];

                                    return GestureDetector(
                                      onTap: () {},
                                      child: Padding(
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(9.0),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .globalNeutral250,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 32,
                                                height: 32,
                                                child: FwIcon(
                                                  // TODO: Consolidate code?
                                                  item.display?.toUpperCase() ==
                                                              'USD' ||
                                                          item.display
                                                                  ?.toUpperCase() ==
                                                              'USDF'
                                                      ? FwIcons.dollarIcon
                                                      : FwIcons.hashLogo,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .globalNeutral550,
                                                  size: 32,
                                                ),
                                              ),
                                              HorizontalSpacer.medium(),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  FwText(
                                                    item.display
                                                            ?.toUpperCase() ??
                                                        '',
                                                    color: FwColor
                                                        .globalNeutral550,
                                                  ),
                                                  VerticalSpacer.xSmall(),
                                                  FwText(
                                                    item.displayAmount ?? '',
                                                    color: FwColor
                                                        .globalNeutral350,
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: Container(),
                                              ),
                                              FwIcon(
                                                FwIcons.caret,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .globalNeutral550,
                                                size: 12.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return VerticalSpacer.small();
                                  },
                                  itemCount: assets.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                ),
                              )
                            : Container(),
                        VerticalSpacer.medium(),
                        StreamBuilder<String>(
                          initialData: null,
                          stream:
                              ProvWalletFlutter.instance.walletAddress.stream,
                          builder: (context, data) {
                            if (data.data == null || data.data!.isEmpty) {
                              return Container();
                            }

                            return Padding(
                              padding: EdgeInsets.only(left: 32, right: 32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FwText(
                                    Strings.walletConnected(data.data),
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  FwButton(
                                    child: FwText(
                                      Strings.disconnect,
                                      color: FwColor.white,
                                    ),
                                    onPressed: () {
                                      ProvWalletFlutter.disconnectWallet();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                        VerticalSpacer.medium(),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: FwButton(
                            child: FwText(
                              Strings.resetWallet,
                            ),
                            onPressed: () async {
                              await ProvWalletFlutter.disconnectWallet();
                              await ProvWalletFlutter.resetWallet();
                              FlutterSecureStorage storage =
                                  FlutterSecureStorage();
                              await storage.deleteAll();

                              Navigator.of(context).popUntil((route) => true);
                              Navigator.push(context, Landing().route());
                            },
                          ),
                        ),
                        VerticalSpacer.large(),
                      ],
                    ),
                  ),
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
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary4
                        : Theme.of(context).colorScheme.white,
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
                  .copyWith(color: Theme.of(context).colorScheme.white),
            ),
          ),
        ],
      ),
    );
  }
}
