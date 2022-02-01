import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/network/models/asset_response.dart';
import 'package:provenance_wallet/screens/dashboard/wallet_portfolio.dart';
import 'package:provenance_wallet/screens/landing/landing.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class DashboardLanding extends StatefulWidget {
  DashboardLanding({
    Key? key,
    required this.walletKey,
  }) : super(key: key);

  // FIXME: State Management
  final GlobalKey<WalletPortfolioState> walletKey;

  @override
  State<StatefulWidget> createState() => DashboardLandingState(walletKey);
}

class DashboardLandingState extends State<DashboardLanding> {
  DashboardLandingState(this.walletKey);
  List<AssetResponse> _assets = [];
  GlobalKey<WalletPortfolioState> walletKey;

  void updateAssets(List<AssetResponse> assets) {
    setState(() {
      _assets = assets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.white,
      padding: EdgeInsets.only(top: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildBody(),
      ),
    );
  }

  List<Widget> _buildBody() {
    List<Widget> list = _assets.isNotEmpty
        ? [
            WalletPortfolio(
              // FIXME: State Management
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
                  final item = _assets[index];

                  return GestureDetector(
                    onTap: () {
                      // TODO: Load Asset
                    },
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Container(
                        padding: EdgeInsets.all(20),
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
                              child: FwIcon(
                                item.display?.toUpperCase() == 'USD' ||
                                        item.display?.toUpperCase() == 'USDF'
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FwText(
                                  item.display?.toUpperCase() ?? '',
                                  color: FwColor.globalNeutral550,
                                ),
                                VerticalSpacer.xSmall(),
                                FwText(
                                  item.displayAmount ?? '',
                                  color: FwColor.globalNeutral350,
                                ),
                              ],
                            ),
                            Expanded(child: Container()),
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
                itemCount: _assets.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ),
          ]
        : [
            WalletPortfolio(
              key: walletKey,
            ),
            Container(),
            Container(),
            Container(),
            Container(),
          ];
    list.add(VerticalSpacer.medium());
    list.add(StreamBuilder<String>(
      initialData: null,
      stream: ProvWalletFlutter.instance.walletAddress.stream,
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
    ));
    list.add(Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.white,
      ),
    ));
    list.add(VerticalSpacer.medium());
    list.add(_buildResetButton());
    list.add(VerticalSpacer.large());

    return list;
  }

  Widget _buildResetButton() {
    // TODO: Remove me? If this is just for development, that is.
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: FwButton(
        child: FwText(
          Strings.resetWallet,
        ),
        onPressed: () async {
          await ProvWalletFlutter.disconnectWallet();
          await ProvWalletFlutter.resetWallet();
          FlutterSecureStorage storage = FlutterSecureStorage();
          await storage.deleteAll();

          Navigator.of(context).popUntil((route) => true);
          // Pretty sure that this is creating an additional view on the stack when one already exists.
          // If this is just for development no change is needed.
          Navigator.push(context, Landing().route());
        },
      ),
    );
  }
}
