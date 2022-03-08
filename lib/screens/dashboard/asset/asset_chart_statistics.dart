import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_chart_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class AssetChartStatistics extends StatelessWidget {
  const AssetChartStatistics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = get<AssetChartBloc>();

    return Column(
      children: [
        Row(
          children: const [
            PwText(
              Strings.statistics,
              style: PwTextStyle.headline4,
            ),
          ],
        ),
        VerticalSpacer.small(),
        StreamBuilder<AssetChartDetails?>(
          initialData: bloc.chartDetails.value,
          stream: bloc.chartDetails,
          builder: (context, snapshot) {
            final stats = snapshot.data?.assetStatistics;
            if (stats == null) {
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
                mainAxisSpacing: Spacing.xxLarge,
                childAspectRatio: 2.8,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PwText(
                        Strings.dayVolume,
                        style: PwTextStyle.footnote,
                        color: PwColor.neutral200,
                      ),
                      VerticalSpacer.xSmall(),
                      PwText(
                        stats.dayVolume.toString(),
                        color: PwColor.neutralNeutral,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PwText(
                        Strings.changeAmount,
                        style: PwTextStyle.footnote,
                        color: PwColor.neutral200,
                      ),
                      VerticalSpacer.xSmall(),
                      PwText(
                        '\$${stats.amountChange.toStringAsFixed(3)}',
                        color: PwColor.neutralNeutral,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PwText(
                        Strings.dayHigh,
                        style: PwTextStyle.footnote,
                        color: PwColor.neutral200,
                      ),
                      VerticalSpacer.xSmall(),
                      PwText(
                        '\$${stats.dayHigh.toStringAsFixed(3)}',
                        color: PwColor.neutralNeutral,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PwText(
                        Strings.dayLow,
                        style: PwTextStyle.footnote,
                        color: PwColor.neutral200,
                      ),
                      VerticalSpacer.xSmall(),
                      PwText(
                        '\$${stats.dayLow.toStringAsFixed(3)}',
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
