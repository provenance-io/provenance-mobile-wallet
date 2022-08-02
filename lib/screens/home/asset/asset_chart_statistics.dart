import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/asset/asset_chart_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class AssetChartStatistics extends StatelessWidget {
  const AssetChartStatistics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    final bloc = get<AssetChartBloc>();

    return Column(
      children: [
        Row(
          children: [
            PwText(
              strings.statistics,
              style: PwTextStyle.headline4,
            ),
          ],
        ),
        VerticalSpacer.small(),
        StreamBuilder<AssetChartDetails?>(
          initialData: bloc.chartDetails.value,
          stream: bloc.chartDetails,
          builder: (context, snapshot) {
            final asset = snapshot.data?.asset;
            if (asset == null) {
              return Container();
            }

            return Container(
              color: Theme.of(context).colorScheme.neutral700,
              child: GridView.count(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.large,
                  vertical: Spacing.medium,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 0.0,
                crossAxisCount: 2,
                mainAxisSpacing: Spacing.large,
                childAspectRatio: 2.8,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PwText(
                        strings.dayVolume,
                        style: PwTextStyle.footnote,
                        color: PwColor.neutral200,
                      ),
                      VerticalSpacer.xSmall(),
                      PwText(
                        '${asset.dailyVolume ?? strings.assetChartNotAvailable}',
                        color: PwColor.neutralNeutral,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PwText(
                        strings.currentPrice,
                        style: PwTextStyle.footnote,
                        color: PwColor.neutral200,
                      ),
                      VerticalSpacer.xSmall(),
                      PwText(
                        '\$${asset.usdPrice}',
                        color: PwColor.neutralNeutral,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PwText(
                        strings.dayHigh,
                        style: PwTextStyle.footnote,
                        color: PwColor.neutral200,
                      ),
                      VerticalSpacer.xSmall(),
                      PwText(
                        '\$${asset.dailyHigh ?? strings.assetChartNotAvailable}',
                        color: PwColor.neutralNeutral,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PwText(
                        strings.dayLow,
                        style: PwTextStyle.footnote,
                        color: PwColor.neutral200,
                      ),
                      VerticalSpacer.xSmall(),
                      PwText(
                        '\$${asset.dailyLow ?? strings.assetChartNotAvailable}',
                        color: PwColor.neutralNeutral,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
