import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_autosizing_text.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/extension/coin_extension.dart';
import 'package:provenance_wallet/screens/dashboard/asset/dashboard_asset_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/landing/connection_details_modal.dart';
import 'package:provenance_wallet/screens/dashboard/landing/wallet_portfolio.dart';
import 'package:provenance_wallet/screens/dashboard/notification_bar.dart';
import 'package:provenance_wallet/screens/dashboard/wallets/wallets_screen.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_state.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_status.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class DashboardLandingTab extends StatefulWidget {
  const DashboardLandingTab({
    Key? key,
  }) : super(key: key);

  static final keyWalletNameText =
      ValueKey('$DashboardLandingTab.wallet_name_text');
  static final keyWalletAddressText =
      ValueKey('$DashboardLandingTab.wallet_address_text');

  @override
  _DashboardLandingTabState createState() => _DashboardLandingTabState();
}

class _DashboardLandingTabState extends State<DashboardLandingTab> {
  @override
  Widget build(BuildContext context) {
    final bloc = get<DashboardBloc>();
    final walletService = get<WalletService>();

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
                  initialData: bloc.sessionEvents.state.value,
                  stream: bloc.sessionEvents.state,
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
                            final walletId =
                                walletService.events.selected.value?.id;
                            if (walletId != null) {
                              final success =
                                  await bloc.tryRestoreSession(walletId);
                              if (!success) {
                                final addressData = await Navigator.of(
                                  context,
                                ).push(
                                  QRCodeScanner(
                                    isValidCallback: (input) {
                                      return Future.value(input.isNotEmpty);
                                    },
                                  ).route(),
                                );

                                if (addressData != null) {
                                  bloc
                                      .connectSession(walletId, addressData)
                                      .catchError((err) {
                                    PwDialog.showError(
                                      context,
                                      exception: err,
                                    );
                                  });
                                }
                              }
                            }
                          }
                        },
                        child: icon,
                      ),
                    );
                  },
                ),
              ],
              centerTitle: false,
              title: StreamBuilder<WalletDetails?>(
                initialData: walletService.events.selected.value,
                stream: walletService.events.selected,
                builder: (context, snapshot) {
                  final details = snapshot.data;

                  final name = details?.name ?? '';
                  final walletAddress = details?.address ?? '';
                  final coin = details?.coin;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PwText(
                        name,
                        key: DashboardLandingTab.keyWalletNameText,
                        style: PwTextStyle.subhead,
                        overflow: TextOverflow.fade,
                      ),
                      Row(
                        children: [
                          PwText(
                            walletAddress.abbreviateAddress(),
                            key: DashboardLandingTab.keyWalletAddressText,
                            style: PwTextStyle.body,
                          ),
                          if (coin != null) HorizontalSpacer.large(),
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
                    builder: (context) => WalletsScreen(),
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
            VerticalSpacer.xxLarge(),
            WalletPortfolio(),
            VerticalSpacer.xxLarge(),
            StreamBuilder<List<Asset>?>(
              initialData: bloc.assetList.value,
              stream: bloc.assetList,
              builder: (context, snapshot) {
                final assets = snapshot.data ?? [];

                return assets.isEmpty
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(
                          left: Spacing.xxLarge,
                          right: Spacing.xxLarge,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            PwText(
                              Strings.myAssets,
                              style: PwTextStyle.title,
                            ),
                          ],
                        ),
                      );
              },
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
                    final assets = snapshot.data ?? [];

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
                                final coin =
                                    walletService.events.selected.value?.coin;
                                if (coin != null) {
                                  get<DashboardAssetBloc>()
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
}
