import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class WalletPortfolio extends StatefulWidget {
  WalletPortfolio({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => WalletPortfolioState();
}

class WalletPortfolioState extends State<WalletPortfolio> {
  String _walletValue = "";

  void updateValue(String text) {
    setState(() {
      _walletValue = text;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    _walletValue,
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
                child: FwIcon(
                  FwIcons.upArrow,
                  size: 24,
                  color: Theme.of(context).colorScheme.white,
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
                child: FwIcon(
                  FwIcons.downArrow,
                  size: 24,
                  color: Theme.of(context).colorScheme.white,
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
                    child: FwIcon(
                      snapshot.data == WallectConnectStatus.disconnected
                          ? FwIcons.walletConnect
                          : FwIcons.close,
                      size: 15,
                      color: Theme.of(context).colorScheme.white,
                    ),
                  ),
                ),
                VerticalSpacer.xSmall(),
                FwText(
                  snapshot.data == WallectConnectStatus.disconnected
                      ? Strings.walletConnect
                      : Strings.disconnect,
                  color: FwColor.white,
                  style: FwTextStyle.s,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
