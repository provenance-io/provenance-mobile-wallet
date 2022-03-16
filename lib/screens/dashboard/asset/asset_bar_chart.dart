import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_chart_bloc.dart';
import 'package:provenance_wallet/util/get.dart';

class AssetBarChart extends StatefulWidget {
  const AssetBarChart({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AssetBarChartState();
}

class AssetBarChartState extends State<AssetBarChart> {
  @override
  Widget build(BuildContext context) {
    final bloc = get<AssetChartBloc>();

    return AspectRatio(
      aspectRatio: 323 / 228,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Colors.transparent,
        child: StreamBuilder<AssetChartDetails?>(
          initialData: bloc.chartDetails.value,
          stream: bloc.chartDetails,
          builder: (context, snapshot) {
            final details = snapshot.data;
            if (details == null ||
                (details.graphItemList.isEmpty && !details.isComingSoon)) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                ],
              );
            }
            final graphList = details.graphItemList;

            return BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.transparent,
                    tooltipPadding: const EdgeInsets.all(0),
                    tooltipMargin: 0,
                    getTooltipItem: (
                      BarChartGroupData group,
                      int groupIndex,
                      BarChartRodData rod,
                      int rodIndex,
                    ) {
                      return BarTooltipItem(
                        "",
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    showTitles: false,
                    getTextStyles: (context, value) => const TextStyle(
                      color: Colors.transparent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    margin: 1,
                    getTitles: (double value) {
                      return '';
                    },
                  ),
                  leftTitles: SideTitles(showTitles: false),
                  topTitles: SideTitles(showTitles: false),
                  rightTitles: SideTitles(showTitles: false),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: [
                  ...graphList
                      .mapIndexed(
                        (index, e) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              y: e.price,
                              colors: [
                                Theme.of(context).colorScheme.secondary300,
                              ],
                              width: 1,
                            ),
                          ],
                          showingTooltipIndicators: [0],
                        ),
                      )
                      .toList(),
                ],
                alignment: BarChartAlignment.spaceAround,
                maxY: graphList.map((e) => e.price).reduce(max),
              ),
            );
          },
        ),
      ),
    );
  }
}
