import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/network/models/asset_response.dart';
import 'package:provenance_wallet/screens/dashboard/landing/reset_button.dart';
import 'package:provenance_wallet/util/strings.dart';

import 'wallet_portfolio.dart';

class WalletConnectWithAssets extends StatelessWidget {
  WalletConnectWithAssets({
    Key? key,
    required this.walletKey,
    required this.assets,
  }) : super(key: key);

  // FIXME: State Management
  final GlobalKey<WalletPortfolioState> walletKey;

  final List<AssetResponse> assets;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WalletPortfolio(
          key: walletKey,
        ),
        VerticalSpacer.medium(),
        Padding(
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
        ),
        VerticalSpacer.medium(),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(left: 20, right: 20),
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9.0),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.globalNeutral250,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          child: FwIcon(
                            item.display?.toUpperCase() == 'USD' ||
                                    item.display?.toUpperCase() == 'USDF'
                                ? FwIcons.dollarIcon
                                : FwIcons.hashLogo,
                            color:
                                Theme.of(context).colorScheme.globalNeutral550,
                            size: 32,
                          ),
                        ),
                        HorizontalSpacer.medium(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FwText(
                              item.display?.toUpperCase() ?? '',
                              color: FwColor.globalNeutral550,
                              style: FwTextStyle.mSemiBold,
                            ),
                            VerticalSpacer.xSmall(),
                            FwText(
                              item.displayAmount ?? '',
                              color: FwColor.globalNeutral350,
                              style: FwTextStyle.sSemiBold,
                            ),
                          ],
                        ),
                        Expanded(child: Container()),
                        FwIcon(
                          FwIcons.caret,
                          color: Theme.of(context).colorScheme.globalNeutral550,
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
            physics: AlwaysScrollableScrollPhysics(),
          ),
        ),
        VerticalSpacer.medium(),
        ResetButton(),
        VerticalSpacer.large(),
      ],
    );
  }
}
