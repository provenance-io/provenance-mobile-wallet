import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/button.dart';
import 'package:flutter_tech_wallet/network/models/asset_response.dart';
import 'package:flutter_tech_wallet/screens/landing/landing.dart';
import 'package:flutter_tech_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

import '../qr_code_scanner.dart';

class DashboardLanding extends StatefulWidget {
  DashboardLanding({
    Key? key,
    required this.walletValue,
    required this.assets,
  }) : super(key: key);

  final String walletValue;
  final List<AssetResponse> assets;

  @override
  State<StatefulWidget> createState() =>
      DashboardLandingState(walletValue, assets);
}

class DashboardLandingState extends State<DashboardLanding> {
  DashboardLandingState(this.walletValue, this.assets);

  String walletValue;
  List<AssetResponse> assets;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildBody(),
      ),
    );
  }

  Widget _buildCurrentPortfolio() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.globalNeutral600Black,
          borderRadius: BorderRadius.circular(11.0),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 17, right: 17),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FwText(
                    Strings.portfolioValue,
                    color: FwColor.white,
                    style: FwTextStyle.sBold,
                  ),
                  FwText(
                    walletValue,
                    color: FwColor.white,
                    style: FwTextStyle.h6,
                  ),
                ],
              ),
              SizedBox(
                height: 17,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 'Send' logic here.
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .globalNeutral450,
                              borderRadius: BorderRadius.circular(
                                23,
                              ),
                            ),
                            height: 46,
                            width: 46,
                            child: Center(
                              child: FwIcon(
                                FwIcons.upArrow,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          VerticalSpacer.xSmall(),
                          FwText(
                            Strings.send,
                            color: FwColor.white,
                            style: FwTextStyle.s,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 'Receive' logic here.
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .globalNeutral450,
                              borderRadius: BorderRadius.circular(
                                23,
                              ),
                            ),
                            height: 46,
                            width: 46,
                            child: Center(
                              child: FwIcon(
                                FwIcons.downArrow,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          VerticalSpacer.xSmall(),
                          FwText(
                            Strings.receive,
                            color: FwColor.white,
                            style: FwTextStyle.s,
                          ),
                        ],
                      ),
                    ),
                  ),
                  StreamBuilder<WallectConnectStatus>(
                    stream:
                        ProvWalletFlutter.instance.walletConnectStatus.stream,
                    initialData: WallectConnectStatus.disconnected,
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Container(
                          width: 100,
                        );
                      }

                      if (snapshot.data == WallectConnectStatus.disconnected) {
                        return Container(
                          width: 100,
                          child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.of(
                                context,
                              ).push(
                                QRCodeScanner().route(),
                              );
                              ProvWalletFlutter.connectWallet(
                                result as String,
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.globalNeutral450,
                                    borderRadius: BorderRadius.circular(
                                      23,
                                    ),
                                  ),
                                  height: 46,
                                  width: 46,
                                  child: Center(
                                    child: FwIcon(
                                      FwIcons.walletConnect,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                VerticalSpacer.xSmall(),
                                FwText(
                                  Strings.walletConnect,
                                  color: FwColor.white,
                                  style: FwTextStyle.s,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Container(
                        width: 100,
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    var list = assets.isNotEmpty
        ? [
            _buildCurrentPortfolio(),
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
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final item = assets[index];

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
                itemCount: assets.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ),
          ]
        : [
            _buildCurrentPortfolio(),
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
        color: Colors.white,
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
