import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_chart_bloc.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/util/get.dart';

class AssetBarChart extends StatelessWidget {
  const AssetBarChart(
    this.timeInterval, {
    Key? key,
    this.graphColor = Colors.blue,
    this.graphFillColor = Colors.white,
    this.labelColor = Colors.white,
  }) : super(key: key);

  final GraphingDataValue timeInterval;
  final Color graphColor;
  final Color graphFillColor;
  final Color labelColor;

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

            final isDataReady = (details?.isComingSoon ?? true) ||
                (details?.graphItemList.isNotEmpty ?? false);

            return (isDataReady)
                ? _buildGraph(context, details!)
                : _buildWaitingWidget(context);
          },
        ),
      ),
    );
  }

  Widget _buildWaitingWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildGraph(BuildContext context, AssetChartDetails details) {
    final textDirection =
        context.findAncestorWidgetOfExactType<Directionality>()!;

    const xLabelAngle = 315.0;
    const yLabelAngle = 315.0;

    final labelStyle = TextStyle(
      color: labelColor,
      fontWeight: FontWeight.bold,
      fontSize: 10,
      overflow: TextOverflow.ellipsis,
    );

    final graphList = details.graphItemList;

    double maxY = double.minPositive;
    double maxX = double.minPositive;
    double minY = double.maxFinite;
    double minX = double.maxFinite;

    for (var item in graphList) {
      final y = item.price;
      final x = item.timestamp.millisecondsSinceEpoch.toDouble();

      maxY = max(maxY, y);
      minY = min(minY, y);
      maxX = max(maxX, x);
      minX = min(minX, x);
    }

    final xFormatter = _formatterForGraphingData(DateTimeRange(
      start: DateTime.fromMillisecondsSinceEpoch(minX.toInt()),
      end: DateTime.fromMillisecondsSinceEpoch(maxX.toInt()),
    ));
    final yFormatter = intl.NumberFormat.compactSimpleCurrency(
      decimalDigits: 2,
    );

    final bottomSize = _sizeFromRotatedText(
      xFormatter.format(DateTime.now()),
      xLabelAngle,
      textDirection,
      labelStyle,
    );

    final leftSize = _sizeFromRotatedText(
      yFormatter.format(0.08),
      yLabelAngle,
      textDirection,
      labelStyle,
    );
    final yRange = maxY - minY;
    const valueAdjustment = .05;

    final adjustmentY = yRange * valueAdjustment;

    return LineChart(
      LineChartData(
        maxY: maxY + adjustmentY,
        minY: max(0.0, minY - adjustmentY),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            textAlign: TextAlign.center,
            showTitles: true,
            reservedSize: bottomSize.height,
            rotateAngle: xLabelAngle,
            getTextStyles: (context, value) => labelStyle,
            getTitles: (double value) {
              final index = value.toInt();
              final item = graphList[index];
              final timeStamp = DateTime.fromMillisecondsSinceEpoch(
                item.timestamp.millisecondsSinceEpoch,
              );

              return xFormatter.format(timeStamp);
            },
            checkToShowTitle: (
              minValue,
              maxValue,
              sideTitles,
              appliedInterval,
              value,
            ) {
              return true;
            },
          ),
          leftTitles: SideTitles(
            showTitles: true,
            textAlign: TextAlign.center,
            reservedSize: leftSize.width,
            rotateAngle: yLabelAngle,
            getTextStyles: (context, value) => labelStyle,
            getTitles: (double value) => yFormatter.format(value),
            checkToShowTitle: (
              minValue,
              maxValue,
              sideTitles,
              appliedInterval,
              value,
            ) {
              return true;
            },
          ),
          topTitles: SideTitles(showTitles: false),
          rightTitles: SideTitles(showTitles: false),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        lineTouchData: LineTouchData(
          enabled: false,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.transparent,
            tooltipPadding: const EdgeInsets.all(0),
            tooltipMargin: 0,
            getTooltipItems: null,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            preventCurveOverShooting: true,
            isCurved: true,
            colors: [graphColor],
            spots: graphList
                .mapIndexed(
                  (index, element) => FlSpot(
                    index.toDouble(),
                    element.price,
                  ),
                )
                .toList(),
            belowBarData: BarAreaData(
              show: true,
              gradientFrom: const Offset(0, 0),
              gradientTo: const Offset(0, 1),
              colors: [
                graphColor,
                graphFillColor,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Size _sizeFromRotatedText(
    String text,
    double rotation,
    Directionality textDecoration,
    TextStyle labelStyle,
  ) {
    final xTextPainter = TextPainter(
      textDirection: textDecoration.textDirection,
      maxLines: 1,
      textAlign: TextAlign.center,
      text: TextSpan(
        style: labelStyle,
        text: text,
      ),
    );

    final originalSize = (xTextPainter..layout()).size;

    toRads(double degrees) => (2.0 * pi) * (degrees / 360.0);

    final degreeInRads = toRads(rotation);

    final lengthFromCenterX = originalSize.width / 2;
    final lengthFromCenterY = originalSize.height / 2;

    rotatePoint(
      double x,
      double y,
      double angle,
    ) {
      final newX = (x * cos(angle)) - (y * sin(angle));
      final newY = (x * sin(angle)) + (y * cos(angle));

      return Point(newX, newY);
    }

    final topLeft = rotatePoint(
      -lengthFromCenterX,
      -lengthFromCenterY,
      degreeInRads,
    );
    final topRight = rotatePoint(
      lengthFromCenterX,
      -lengthFromCenterY,
      degreeInRads,
    );
    final bottomLeft = rotatePoint(
      -lengthFromCenterX,
      lengthFromCenterY,
      degreeInRads,
    );
    final bottomRight = rotatePoint(
      lengthFromCenterX,
      lengthFromCenterY,
      degreeInRads,
    );

    final xValues = [
      topLeft.x,
      topRight.x,
      bottomLeft.x,
      bottomRight.x,
    ];
    final yValues = [
      topLeft.y,
      topRight.y,
      bottomLeft.y,
      bottomRight.y,
    ];

    final leftMost = xValues.reduce(min);
    final rightMost = xValues.reduce(max);

    final topMost = yValues.reduce(min);
    final bottomMost = yValues.reduce(max);

    return Size(
      (rightMost - leftMost + 8).toDouble(),
      (bottomMost - topMost).toDouble(),
    );
  }

  intl.DateFormat _formatterForGraphingData(DateTimeRange dateRange) {
    String dateFormat = "MM/dd HH:mm";

    return intl.DateFormat(dateFormat);
  }
}
