import 'package:flutter/scheduler.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/notification_bell.dart';
import 'package:provenance_wallet/common/widgets/pw_autosizing_text.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/extension/coin_extension.dart';
import 'package:provenance_wallet/screens/action/action_flow.dart';
import 'package:provenance_wallet/screens/home/accounts/accounts_screen.dart';
import 'package:provenance_wallet/screens/home/asset/dashboard_tab_bloc.dart';
import 'package:provenance_wallet/screens/home/dashboard/account_portfolio.dart';
import 'package:provenance_wallet/screens/home/dashboard/wallet_connect_button.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/home/notification_bar.dart';
import 'package:provenance_wallet/services/account_notification_service/account_notification_service.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/multi_sig_service/multi_sig_service.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/utils.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    Key? key,
  }) : super(key: key);

  static final keyAccountNameText = ValueKey('$Dashboard.account_name_text');
  static final keyAccountAddressText =
      ValueKey('$Dashboard.account_address_text');
  static final keyOpenAccountsButton =
      ValueKey('$Dashboard.open_accounts_button');
  static final keyListColumn = ValueKey('$Dashboard.list_column');
  static Key keyAssetAmount(String denom) =>
      ValueKey('$Dashboard.asset_amount_$denom');

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _subscriptions = CompositeSubscription();
  final _notificationBellNotifier = ValueNotifier<int>(0);
  late WalletConnectQueueService _connectQueueService;
  late MultiSigService _multiSigService;
  late AccountNotificationService _accountNotificationService;
  var _accountNotificationCount = 0;

  @override
  void initState() {
    super.initState();

    _connectQueueService = get<WalletConnectQueueService>();
    _connectQueueService.addListener(_updateBellCount);

    _multiSigService = get<MultiSigService>();
    _multiSigService.addListener(_updateBellCount);

    _accountNotificationService = get<AccountNotificationService>();
    _accountNotificationService.notifications.listen((e) {
      _accountNotificationCount = e.length;
      _updateBellCount();
    }).addTo(_subscriptions);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _updateBellCount();
    });
  }

  @override
  void dispose() {
    _subscriptions.dispose();
    _connectQueueService.removeListener(_updateBellCount);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bloc = Provider.of<HomeBloc>(context, listen: false);

    final accountService = get<AccountService>();
    final isTallScreen = (mediaQuery.size.height > 600);

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
                WalletConnectButton(),
                HorizontalSpacer.large(),
                ValueListenableBuilder<int>(
                  valueListenable: _notificationBellNotifier,
                  builder: (context, value, child) {
                    return NotificationBell(
                      notificationCount: value,
                      placeCount: 1,
                      onClicked: _onNotificationBellClicked,
                    );
                  },
                ),
              ],
              centerTitle: false,
              title: StreamBuilder<TransactableAccount?>(
                initialData: accountService.events.selected.value,
                stream: accountService.events.selected,
                builder: (context, snapshot) {
                  final details = snapshot.data;

                  final name = details?.name ?? '';
                  final accountAddress = details?.address ?? '';
                  final coin = details?.coin;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PwText(
                        name,
                        key: Dashboard.keyAccountNameText,
                        style: PwTextStyle.footnote,
                        overflow: TextOverflow.fade,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: PwText(
                              "(${abbreviateAddress(accountAddress)})",
                              key: Dashboard.keyAccountAddressText,
                              style: PwTextStyle.footnote,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          if (coin != null)
                            PwText(
                              coin.displayName,
                              style: PwTextStyle.footnote,
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              leading: GestureDetector(
                key: Dashboard.keyOpenAccountsButton,
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  await showDialog(
                    barrierColor: Theme.of(context).colorScheme.neutral750,
                    useSafeArea: true,
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => Provider.value(
                      value: bloc,
                      child: AccountsScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 18,
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
            VerticalSpacer.xxLarge(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.large,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PwText(
                    Strings.of(context).myAssets,
                    style: PwTextStyle.subhead,
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
            VerticalSpacer.medium(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await bloc.load(
                    showLoading: false,
                  );
                },
                color: Theme.of(context).colorScheme.indicatorActive,
                child: StreamBuilder<List<Asset>?>(
                  initialData: bloc.assetList.value,
                  stream: bloc.assetList,
                  builder: (context, snapshot) {
                    var assets = snapshot.data ?? [];

                    if (assets.isEmpty) {
                      assets.add(Asset.fake(
                        denom: nHashDenom,
                        amount: "0",
                        description: "",
                        display: Strings.displayHASH,
                        displayAmount: "0",
                        exponent: 9,
                        usdPrice: 0,
                      ));
                    }

                    return ListView.separated(
                      key: Dashboard.keyListColumn,
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.large,
                      ),
                      itemBuilder: (context, index) {
                        final item = assets[index];

                        return Column(
                          children: [
                            if (index == 0) PwListDivider(),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                final coin =
                                    accountService.events.selected.value?.coin;
                                if (coin != null) {
                                  Provider.of<DashboardTabBloc>(context,
                                          listen: false)
                                      .openAsset(coin, item);
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
                                            key: Dashboard.keyAssetAmount(
                                                item.display),
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

  void _updateBellCount() async {
    final connectGroups = await _connectQueueService.loadAllGroups();

    final connectCounts =
        connectGroups.map((group) => group.actionLookup.length);

    final connectCount = (connectCounts.isEmpty)
        ? 0
        : connectCounts.reduce((value, element) => value + element);

    // Attempt to get the count right first try, but don't wait forever.
    await Future.any([
      _multiSigService.initialized,
      Future.delayed(
        Duration(
          seconds: 1,
        ),
      ),
    ]);

    _notificationBellNotifier.value = connectCount +
        _multiSigService.items.length +
        _accountNotificationCount;
  }
}
