import 'package:flutter_svg/flutter_svg.dart';
import 'package:provenance_wallet/common/models/asset.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
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
    );
  }
}
