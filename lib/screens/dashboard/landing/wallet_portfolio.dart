import 'package:provenance_wallet/common/models/asset.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/send_flow/send_flow.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

typedef OnAddressCaptured = Future<void> Function(String address);

class WalletPortfolio extends StatelessWidget {
  const WalletPortfolio({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assetStream = get<DashboardBloc>().assetList;

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
          StreamBuilder<List<Asset>>(
            initialData: assetStream.value,
            stream: assetStream,
            builder: (context, snapshot) {
              double portfolioValue = 0;

              if (snapshot.data != null && (snapshot.data ?? []).isNotEmpty) {
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SendFlow(),
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
                  // TODO: 'Receive' logic here.
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
