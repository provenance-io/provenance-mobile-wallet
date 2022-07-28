import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/notification_bell.dart';
import 'package:provenance_wallet/common/widgets/pw_autosizing_text.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/extension/coin_extension.dart';
import 'package:provenance_wallet/screens/action/action_flow.dart';
import 'package:provenance_wallet/screens/home/accounts/accounts_screen.dart';
import 'package:provenance_wallet/screens/home/asset/dashboard_tab_bloc.dart';
import 'package:provenance_wallet/screens/home/dashboard/account_portfolio.dart';
import 'package:provenance_wallet/screens/home/dashboard/connection_details_modal.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/home/notification_bar.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_state.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_status.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    Key? key,
  }) : super(key: key);

  static final keyAccountNameText = ValueKey('$Dashboard.account_name_text');
  static final keyAccountAddressText =
      ValueKey('$Dashboard.account_address_text');

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _notificationBellNotifier = ValueNotifier<int>(0);
  late WalletConnectQueueService _connectQueueService;

  @override
  void initState() {
    super.initState();

    _connectQueueService = get<WalletConnectQueueService>();
    _connectQueueService.addListener(_connectQueueUpdated);
  }

  @override
  void dispose() {
    _connectQueueService.removeListener(_connectQueueUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bloc = get<HomeBloc>();

    final accountService = get<AccountService>();
    final isTallScreen = (mediaQuery.size.height > 600);
    final _keyValueService = get<KeyValueService>();
    final _walletConnectService = get<WalletConnectService>();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.imagePaths.background),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NotificationBar(),
            AppBar(
              primary: false,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              actions: [
                StreamBuilder<WalletConnectSessionState>(
                  initialData: _walletConnectService.sessionEvents.state.value,
                  stream: _walletConnectService.sessionEvents.state,
                  builder: (context, snapshot) {
                    final connected = snapshot.data?.status ==
                        WalletConnectSessionStatus.connected;
                    Widget icon;
                    switch (snapshot.data?.status) {
                      case WalletConnectSessionStatus.disconnected:
                        icon = PwIcon(
                          PwIcons.qr,
                          color: Theme.of(context).colorScheme.neutralNeutral,
                          size: 48.0,
                        );
                        break;
                      case WalletConnectSessionStatus.connected:
                        icon = PwIcon(
                          PwIcons.linked,
                          color: Theme.of(context).colorScheme.neutralNeutral,
                          size: 48.0,
                        );
                        break;
                      default:
                        icon = Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            PwIcon(
                              PwIcons.linked,
                              color: Theme.of(context)
                                  .colorScheme
                                  .neutralNeutral
                                  .withAlpha(128),
                              size: 48.0,
                            ),
                            SizedBox(
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .neutralNeutral,
                              ),
                              height: 48,
                              width: 48,
                            ),
                          ],
                        );
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                        right: Spacing.xxLarge,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          if (connected) {
                            showDialog(
                              useSafeArea: true,
                              barrierColor:
                                  Theme.of(context).colorScheme.neutral750,
                              context: context,
                              builder: (context) => ConnectionDetailsModal(),
                            );
                          } else {
                            final accountId =
                                accountService.events.selected.value?.id;

                            if (accountId != null) {
                              final addressData = await Navigator.of(
                                context,
                                rootNavigator: true,
                              ).push(
                                QRCodeScanner(
                                  isValidCallback: (input) {
                                    return Future.value(input.isNotEmpty);
                                  },
                                ).route(),
                              );

                              if (addressData != null) {
                                _walletConnectService
                                    .connectSession(accountId, addressData)
                                    .catchError((err) {
                                  PwDialog.showError(
                                    context,
                                    exception: err,
                                  );
                                });
                              }
                            }
                          }
                        },
                        child: icon,
                      ),
                    );
                  },
                ),
                StreamBuilder<KeyValueData<bool>>(
                  initialData: _keyValueService
                      .stream<bool>(PrefKey.enableMultiSig)
                      .valueOrNull,
                  stream: _keyValueService.stream<bool>(PrefKey.enableMultiSig),
                  builder: (context, snapshot) {
                    final show = snapshot.data?.data ?? false;
                    if (!show) {
                      return Container();
                    }

                    return ValueListenableBuilder<int>(
                        valueListenable: _notificationBellNotifier,
                        builder: (context, value, child) {
                          return NotificationBell(
                            notificationCount: value,
                            placeCount: 1,
                            onClicked: _onNotificationBellClicked,
                          );
                        });
                  },
                ),
              ],
              centerTitle: false,
              title: StreamBuilder<Account?>(
                initialData: accountService.events.selected.value,
                stream: accountService.events.selected,
                builder: (context, snapshot) {
                  final details = snapshot.data;

                  final name = details?.name ?? '';
                  final accountAddress = details?.publicKey?.address ?? '';
                  final coin = details?.publicKey?.coin;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PwText(
                        name,
                        key: Dashboard.keyAccountNameText,
                        style: PwTextStyle.subhead,
                        overflow: TextOverflow.fade,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: PwText(
                              abbreviateAddress(accountAddress),
                              key: Dashboard.keyAccountAddressText,
                              style: PwTextStyle.body,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          if (coin != null)
                            PwText(
                              coin.displayName,
                              style: PwTextStyle.body,
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              leading: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  await showDialog(
                    barrierColor: Theme.of(context).colorScheme.neutral750,
                    useSafeArea: true,
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AccountsScreen(),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    left: Spacing.large,
                    top: 18,
                    bottom: 18,
                  ),
                  child: PwIcon(
                    PwIcons.ellipsis,
                    color: Theme.of(context).colorScheme.neutralNeutral,
                    size: 20,
                  ),
                ),
              ),
            ),
            (isTallScreen) ? VerticalSpacer.xxLarge() : VerticalSpacer.medium(),
            AccountPortfolio(
              labelHeight: (isTallScreen) ? 45 : 30,
            ),
            VerticalSpacer.medium(),
            Padding(
              padding: EdgeInsets.only(
                left: Spacing.xxLarge,
                right: Spacing.xxLarge,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PwText(
                    Strings.myAssets,
                    style: PwTextStyle.title,
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
            VerticalSpacer.medium(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await bloc.load(showLoading: false);
                },
                color: Theme.of(context).colorScheme.indicatorActive,
                child: StreamBuilder<List<Asset>?>(
                  initialData: bloc.assetList.value,
                  stream: bloc.assetList,
                  builder: (context, snapshot) {
                    var assets = snapshot.data ?? [];

                    if (assets.isEmpty) {
                      assets.add(Asset.fake(
                        denom: "nhash",
                        amount: "0",
                        description: "",
                        display: "HASH",
                        displayAmount: "0",
                        exponent: 9,
                        usdPrice: 0,
                      ));
                    }

                    return ListView.separated(
                      padding: EdgeInsets.only(
                        left: Spacing.xxLarge,
                        right: Spacing.xxLarge,
                      ),
                      itemBuilder: (context, index) {
                        final item = assets[index];

                        return Column(
                          children: [
                            if (index == 0) PwListDivider(),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                final coin = accountService
                                    .events.selected.value?.publicKey?.coin;
                                if (coin != null) {
                                  get<DashboardTabBloc>().openAsset(coin, item);
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: EdgeInsets.only(
                                    right: 8,
                                    left: 8,
                                    top: Spacing.xLarge,
                                    bottom: Spacing.xLarge,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Assets.getSvgPictureFrom(
                                          denom: item.denom,
                                          size: 40,
                                        ),
                                      ),
                                      HorizontalSpacer.medium(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          PwText(
                                            item.display,
                                            style: PwTextStyle.bodyBold,
                                          ),
                                          VerticalSpacer.xSmall(),
                                          PwAutoSizingText(
                                            item.formattedAmount,
                                            height: 16,
                                            color: PwColor.neutral200,
                                            style: PwTextStyle.footnote,
                                          ),
                                        ],
                                      ),
                                      Expanded(child: Container()),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          PwText(
                                            item.displayAmount,
                                            color: PwColor.neutral200,
                                            style: PwTextStyle.footnote,
                                          ),
                                          VerticalSpacer.custom(
                                            spacing: 21,
                                          ),
                                        ],
                                      ),
                                      HorizontalSpacer.small(),
                                      PwIcon(
                                        PwIcons.caret,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .neutralNeutral,
                                        size: 12.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return PwListDivider();
                      },
                      itemCount: assets.length,
                      physics: AlwaysScrollableScrollPhysics(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNotificationBellClicked() async {
    final accountService = get<AccountService>();
    final account = accountService.events.selected.value;
    if (account == null) {
      return;
    }

    Navigator.push(context, ActionFlow(account: account).route());
  }

  void _connectQueueUpdated() async {
    final groups = await _connectQueueService.loadAllGroups();
    final counts = groups.map((group) => group.actionLookup.length);
    _notificationBellNotifier.value =
        counts.reduce((value, element) => value + element);
  }
}
