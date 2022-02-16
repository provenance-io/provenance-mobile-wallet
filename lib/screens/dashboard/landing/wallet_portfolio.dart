import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/network/models/asset_response.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/services/wallet_connection_service_status.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

typedef Future<void> OnAddressCaptured(String address);

class WalletPortfolio extends StatelessWidget {
  const WalletPortfolio({Key? key}) : super(key: key);

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
                        // FIXME: How do we get portfolio value?
                        '\$0',
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
    final bloc = get<DashboardBloc>();

    return StreamBuilder<WalletConnectionServiceStatus>(
      initialData: bloc.connectionStatus.value,
      stream: bloc.connectionStatus,
      builder: (context, snapshot) {
        final connected =
            snapshot.data == WalletConnectionServiceStatus.connected;

        return Container(
          width: 100,
          child: GestureDetector(
            onTap: () async {
              if (!connected) {
                final addressData = await Navigator.of(
                  context,
                ).push(
                  QRCodeScanner().route<String?>(),
                );
                if (addressData != null) {
                  bloc.connectWallet(addressData);
                }
              } else {
                bloc.disconnectWallet();
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
                      !connected ? PwIcons.walletConnect : PwIcons.close,
                      size: 15,
                      color: Theme.of(context).colorScheme.white,
                    ),
                  ),
                ),
                VerticalSpacer.xSmall(),
                PwText(
                  !connected ? Strings.walletConnect : Strings.disconnect,
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
