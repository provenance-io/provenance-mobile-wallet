import 'package:faker/faker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provenance_wallet/common/pw_design.dart';

class _BarChart extends StatelessWidget {
  const _BarChart({Key? key}) : super(key: key);

  List<BarChartGroupData> getBarGroups(BuildContext context) {
    var list = <BarChartGroupData>[];
    for (var i = 0; i < 100; i++) {
      list.add(makeBarGraphData(context, i));
    }

    return list;
  }

  BarChartGroupData makeBarGraphData(BuildContext context, int index) {
    var faker = Faker();

    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          y: faker.randomGenerator.decimal(),
          colors: [Theme.of(context).colorScheme.secondary300],
          width: 1,
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }

  @override
  Widget build(BuildContext context) {
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
        barGroups: getBarGroups(context),
        alignment: BarChartAlignment.spaceAround,
        maxY: 1,
      ),
    );
  }
}

class AssetBarChart extends StatefulWidget {
  const AssetBarChart({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AssetBarChartState();
}

class AssetBarChartState extends State<AssetBarChart> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 323 / 228,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Colors.transparent,
        child: const _BarChart(),
      ),
    );
  }
}
