import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/receive_flow/receive_flow.dart';
import 'package:provenance_wallet/screens/send_flow/send_flow.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

typedef OnAddressCaptured = Future<void> Function(String address);

class WalletPortfolio extends StatelessWidget {
  const WalletPortfolio({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = get<DashboardBloc>();

    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.xxLarge,
        right: Spacing.xxLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PwText(
            Strings.portfolioValue,
            color: PwColor.neutralNeutral,
            style: PwTextStyle.subhead,
          ),
          StreamBuilder<List<Asset>?>(
            initialData: bloc.assetList.value,
            stream: bloc.assetList,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return PwText(
                  "\$-.--",
                  color: PwColor.neutralNeutral,
                  style: PwTextStyle.display2,
                );
              }
              double portfolioValue = 0;

              if (snapshot.data!.isNotEmpty) {
                portfolioValue = snapshot.data
                        ?.map((e) => e.usdPrice * double.parse(e.displayAmount))
                        .reduce((value, element) => value + element) ??
                    0;
              }

              return PwText(
                portfolioValue.toCurrency(),
                color: PwColor.neutralNeutral,
                style: PwTextStyle.display2,
              );
            },
          ),
          VerticalSpacer.xLarge(),
          Row(
            children: [
              PwButton(
                minimumWidth: 150,
                minimumHeight: 66,
                child: Column(
                  children: [
                    PwIcon.only(
                      PwIcons.upArrow,
                      width: 14,
                      height: 16,
                      color: Theme.of(context).colorScheme.neutralNeutral,
                    ),
                    VerticalSpacer.xSmall(),
                    PwText(
                      Strings.send,
                      color: PwColor.neutralNeutral,
                      style: PwTextStyle.bodyBold,
                    ),
                  ],
                ),
                onPressed: () async {
                  final walletDetails =
                      await get<WalletService>().getSelectedWallet();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SendFlow(walletDetails!),
                    ),
                  );
                },
              ),
              HorizontalSpacer.small(),
              PwButton(
                minimumWidth: 150,
                minimumHeight: 66,
                child: Column(
                  children: [
                    PwIcon.only(
                      PwIcons.downArrow,
                      width: 14,
                      height: 16,
                      color: Theme.of(context).colorScheme.neutralNeutral,
                    ),
                    VerticalSpacer.xSmall(),
                    PwText(
                      Strings.receive,
                      color: PwColor.neutralNeutral,
                      style: PwTextStyle.bodyBold,
                    ),
                  ],
                ),
                onPressed: () {
                  final walletDetails =
                      get<DashboardBloc>().selectedWallet.value;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceiveFlow(walletDetails!),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
