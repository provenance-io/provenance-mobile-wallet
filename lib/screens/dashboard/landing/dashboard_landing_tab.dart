import 'package:provenance_wallet/common/models/asset.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/network/models/asset_response.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/landing/reset_button.dart';
import 'package:provenance_wallet/screens/dashboard/landing/wallet_portfolio.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class DashboardLandingTab extends StatefulWidget {
  const DashboardLandingTab({Key? key}) : super(key: key);

  @override
  _DashboardLandingTabState createState() => _DashboardLandingTabState();
}

class _DashboardLandingTabState extends State<DashboardLandingTab> {
  @override
  Widget build(BuildContext context) {
    final assetStream = get<DashboardBloc>().assetList;

    return Container(
      padding: EdgeInsets.only(
        top: Spacing.xxLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WalletPortfolio(),
          VerticalSpacer.medium(),
          StreamBuilder<List<Asset>>(
            initialData: assetStream.value,
            stream: assetStream,
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
          VerticalSpacer.medium(),
          Expanded(
            child: StreamBuilder<List<Asset>>(
              initialData: assetStream.value,
              stream: assetStream,
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
                            top: 12,
                            bottom: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                child: PwIcon(
                                  item.display == 'USD' ||
                                          item.display == 'USDF'
                                      ? PwIcons.dollarIcon
                                      : PwIcons.hashLogo,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .globalNeutral550,
                                  size: 32,
                                ),
                              ),
                              HorizontalSpacer.medium(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PwText(
                                    item.display.toUpperCase(),
                                    color: PwColor.globalNeutral550,
                                    style: PwTextStyle.mSemiBold,
                                  ),
                                  VerticalSpacer.xSmall(),
                                  PwText(
                                    item.displayAmount,
                                    color: PwColor.globalNeutral350,
                                    style: PwTextStyle.sSemiBold,
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
    );
  }
}
