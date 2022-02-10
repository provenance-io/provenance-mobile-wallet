import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/network/models/asset_response.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class WalletPortfolio extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WalletPortfolioState();
}

class WalletPortfolioState extends State<WalletPortfolio> {
  @override
  Widget build(BuildContext context) {
    final assetStream = get<DashboardBloc>().assetList;

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
                  PwText(
                    Strings.portfolioValue,
                    color: PwColor.white,
                    style: PwTextStyle.sBold,
                  ),
                  StreamBuilder<List<AssetResponse>>(
                    initialData: assetStream.value,
                    stream: assetStream,
                    builder: (context, snapshot) {
                      final assets = snapshot.data ?? [];

                      return PwText(
                        assets.isNotEmpty
                            ? '\$${assets.map((e) => double.tryParse(e.amount ?? "") ?? 0).reduce((value, element) => value + element).toStringAsFixed(2)}'
                            : '\$0',
                        color: PwColor.white,
                        style: PwTextStyle.h6,
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 17,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSendButton(context),
                  _buildReceiveButton(context),
                  _buildWalletConnectButton(),
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

  Widget _buildSendButton(BuildContext context) {
    return Container(
      width: 100,
      child: GestureDetector(
        onTap: () {
          // TODO: 'Send' logic here.
        },
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.globalNeutral450,
                borderRadius: BorderRadius.circular(
                  23,
                ),
              ),
              height: 46,
              width: 46,
              child: Center(
                child: PwIcon(
                  PwIcons.upArrow,
                  size: 24,
                  color: Theme.of(context).colorScheme.white,
                ),
              ),
            ),
            VerticalSpacer.xSmall(),
            PwText(
              Strings.send,
              color: PwColor.white,
              style: PwTextStyle.s,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiveButton(BuildContext context) {
    return Container(
      width: 100,
      child: GestureDetector(
        onTap: () {
          // TODO: 'Receive' logic here.
        },
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.globalNeutral450,
                borderRadius: BorderRadius.circular(
                  23,
                ),
              ),
              height: 46,
              width: 46,
              child: Center(
                child: PwIcon(
                  PwIcons.downArrow,
                  size: 24,
                  color: Theme.of(context).colorScheme.white,
                ),
              ),
            ),
            VerticalSpacer.xSmall(),
            PwText(
              Strings.receive,
              color: PwColor.white,
              style: PwTextStyle.s,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletConnectButton() {
    return StreamBuilder<WallectConnectStatus>(
      stream: ProvWalletFlutter.instance.walletConnectStatus.stream,
      initialData: WallectConnectStatus.disconnected,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Container(
            width: 100,
          );
        }

        return Container(
          width: 100,
          child: GestureDetector(
            onTap: () async {
              if (snapshot.data == WallectConnectStatus.disconnected) {
                final result = await Navigator.of(
                  context,
                ).push(
                  QRCodeScanner().route(),
                );
                ProvWalletFlutter.connectWallet(
                  result as String,
                );
              } else {
                ProvWalletFlutter.disconnectWallet();
              }
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
                    child: PwIcon(
                      snapshot.data == WallectConnectStatus.disconnected
                          ? PwIcons.walletConnect
                          : PwIcons.close,
                      size: 15,
                      color: Theme.of(context).colorScheme.white,
                    ),
                  ),
                ),
                VerticalSpacer.xSmall(),
                PwText(
                  snapshot.data == WallectConnectStatus.disconnected
                      ? Strings.walletConnect
                      : Strings.disconnect,
                  color: PwColor.white,
                  style: PwTextStyle.s,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
