import 'package:flutter_svg/flutter_svg.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/landing/connection_details_modal.dart';
import 'package:provenance_wallet/screens/dashboard/landing/wallet_portfolio.dart';
import 'package:provenance_wallet/screens/dashboard/wallets/wallets_screen.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connection_service_status.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class DashboardLandingTab extends StatefulWidget {
  const DashboardLandingTab({
    Key? key,
  }) : super(key: key);

  @override
  _DashboardLandingTabState createState() => _DashboardLandingTabState();
}

class _DashboardLandingTabState extends State<DashboardLandingTab> {
  @override
  Widget build(BuildContext context) {
    final bloc = get<DashboardBloc>();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AssetPaths.images.background),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          StreamBuilder<WalletConnectionServiceStatus>(
            initialData: bloc.connectionStatus.value,
            stream: bloc.connectionStatus,
            builder: (context, snapshot) {
              final connected =
                  snapshot.data == WalletConnectionServiceStatus.connected;

              return Padding(
                padding: EdgeInsets.only(
                  right: Spacing.xxLarge,
                ),
                child: GestureDetector(
                  onTap: () async {
                    if (connected) {
                      showDialog(
                        useSafeArea: true,
                        barrierColor: Theme.of(context).colorScheme.neutral750,
                        context: context,
                        builder: (context) => ConnectionDetailsModal(),
                      );
                    } else {
                      final addressData = await Navigator.of(
                        context,
                      ).push(
                        QRCodeScanner().route(),
                      );
                      if (addressData != null) {
                        bloc.connectWallet(addressData);
                      }
                    }
                  },
                  child: PwIcon(
                    connected ? PwIcons.linked : PwIcons.qr,
                    color: Theme.of(context).colorScheme.neutralNeutral,
                    size: 48.0,
                  ),
                ),
              );
            },
          ),
        ],
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<WalletDetails?>(
              initialData: bloc.selectedWallet.value,
              stream: bloc.selectedWallet,
              builder: (context, snapshot) {
                final walletName = snapshot.data?.name ?? "";

                return PwText(
                  walletName,
                  style: PwTextStyle.subhead,
                  overflow: TextOverflow.fade,
                );
              },
            ),
            StreamBuilder<WalletDetails?>(
              initialData: bloc.selectedWallet.value,
              stream: bloc.selectedWallet,
              builder: (context, snapshot) {
                final walletAddress = snapshot.data?.address ?? "";

                return PwText(
                  "(${walletAddress.abbreviateAddress()})",
                  style: PwTextStyle.body,
                );
              },
            ),
          ],
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.images.background),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.only(
          top: Spacing.xxLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WalletPortfolio(),
            VerticalSpacer.xxLarge(),
            StreamBuilder<List<Asset>>(
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
              child: StreamBuilder<List<Asset>>(
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
                            onTap: () {
                              // TODO: Load Asset
                            },
                            child: Padding(
                              padding: EdgeInsets.zero,
                              child: Container(
                                padding: EdgeInsets.only(
                                  right: 16,
                                  left: 16,
                                  top: Spacing.xLarge,
                                  bottom: Spacing.xLarge,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: SvgPicture.asset(
                                        item.image,
                                        width: 40,
                                        height: 40,
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
                                        PwText(
                                          item.formattedAmount,
                                          color: PwColor.neutral200,
                                          style: PwTextStyle.footnote,
                                        ),
                                      ],
                                    ),
                                    Expanded(child: Container()),
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
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
