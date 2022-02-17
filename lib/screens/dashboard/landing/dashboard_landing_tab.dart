import 'package:flutter_svg/flutter_svg.dart';
import 'package:provenance_wallet/common/models/asset.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/landing/reset_button.dart';
import 'package:provenance_wallet/screens/dashboard/landing/wallet_portfolio.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/services/remote_client_details.dart';
import 'package:provenance_wallet/services/wallet_connection_service_status.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

import '../wallets.dart';

class DashboardLandingTab extends StatefulWidget {
  const DashboardLandingTab({
    Key? key,
    required this.walletName,
  }) : super(key: key);
  final String walletName;

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
                      bloc.disconnectWallet();
                    }
                    final addressData = await Navigator.of(
                      context,
                    ).push(
                      QRCodeScanner().route<String?>(),
                    );
                    if (addressData != null) {
                      bloc.connectWallet(addressData);
                    }
                  },
                  child: PwIcon(
                    PwIcons.qr,
                    color: Theme.of(context).colorScheme.white,
                    size: 48.0,
                  ),
                ),
              );
            },
          ),
        ],
        centerTitle: false,
        title: PwText(
          widget.walletName,
          style: PwTextStyle.subhead,
        ),
        leading: Padding(
          padding: EdgeInsets.only(
            left: Spacing.large,
            top: 18,
            bottom: 18,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(Wallets().route());
            },
            child: PwIcon(
              PwIcons.ellipsis,
              color: Theme.of(context).colorScheme.white,
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
            VerticalSpacer.medium(),
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
                          children: [
                            PwText(
                              Strings.myAssets,
                              style: PwTextStyle.title,
                            ),
                          ],
                        ),
                      );
              },
            ),
            StreamBuilder<String?>(
              initialData: get<DashboardBloc>().address.value,
              stream: get<DashboardBloc>().address,
              builder: (context, data) {
                if (data.data == null || data.data!.isEmpty) {
                  return Container();
                }

                return Padding(
                  padding: EdgeInsets.only(
                    left: Spacing.xxLarge,
                    right: Spacing.xxLarge,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PwText(
                        Strings.walletConnected(data.data),
                        style: PwTextStyle.caption,
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

                      return GestureDetector(
                        onTap: () {
                          // TODO: Load Asset
                        },
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: Container(
                            padding: EdgeInsets.only(
                              right: 16,
                              left: 16,
                              top: 20,
                              bottom: 20,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PwText(
                                      item.display,
                                      style: PwTextStyle.bodyBold,
                                    ),
                                    VerticalSpacer.xSmall(),
                                    PwText(
                                      item.displayAmount,
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
                      return PwListDivider();
                    },
                    itemCount: assets.length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                  );
                },
              ),
            ),
            VerticalSpacer.medium(),
            ResetButton(),
            VerticalSpacer.large(),
          ],
        ),
      ),
    );
  }
}
