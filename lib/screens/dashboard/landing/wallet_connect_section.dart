import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/network/models/asset_response.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/landing/reset_button.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

import 'wallet_portfolio.dart';

class WalletConnectSection extends StatefulWidget {
  const WalletConnectSection({Key? key}) : super(key: key);

  @override
  _WalletConnectSectionState createState() => _WalletConnectSectionState();
}

class _WalletConnectSectionState extends State<WalletConnectSection> {
  @override
  Widget build(BuildContext context) {
    final assetStream = get<DashboardBloc>().assetList;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WalletPortfolio(),
        VerticalSpacer.medium(),
        StreamBuilder<List<AssetResponse>>(
          initialData: assetStream.value,
          stream: assetStream,
          builder: (context, snapshot) {
            final assets = snapshot.data ?? [];

            return assets.isEmpty
                ? Container()
                : Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        PwText(
                          Strings.myAssets,
                          color: PwColor.globalNeutral550,
                          style: PwTextStyle.h6,
                        ),
                      ],
                    ),
                  );
          },
        ),
        VerticalSpacer.medium(),
        Expanded(
          child: StreamBuilder<List<AssetResponse>>(
            initialData: assetStream.value,
            stream: assetStream,
            builder: (context, snapshot) {
              final assets = snapshot.data ?? [];

              return ListView.separated(
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
                            color:
                                Theme.of(context).colorScheme.globalNeutral250,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              child: PwIcon(
                                item.display?.toUpperCase() == 'USD' ||
                                        item.display?.toUpperCase() == 'USDF'
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
                                  item.display?.toUpperCase() ?? '',
                                  color: PwColor.globalNeutral550,
                                  style: PwTextStyle.mSemiBold,
                                ),
                                VerticalSpacer.xSmall(),
                                PwText(
                                  item.displayAmount ?? '',
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
                  return VerticalSpacer.small();
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
    );
  }
}
