import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_chart_bloc.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class AssetChartPoinData {
  AssetChartPoinData(
    this.price,
    this.percentChange,
    this.timestamp,
  );

  final double price;
  final double percentChange;
  final DateTime timestamp;
}

class AssetBarChart extends StatelessWidget {
  AssetBarChart(
    this.timeInterval, {
    Key? key,
    this.graphColor = Colors.blue,
    this.graphFillColor = Colors.white,
    this.labelColor = Colors.white,
    this.isCompact = false,
  }) : super(key: key);

  final GraphingDataValue timeInterval;
  final Color graphColor;
  final Color graphFillColor;
  final Color labelColor;
  final bool isCompact;
  final ValueNotifier<AssetChartPoinData?> changeNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    final bloc = get<AssetChartBloc>();

    return AspectRatio(
      aspectRatio: (isCompact) ? 3 / 2 : 323 / 228,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Colors.transparent,
        child: StreamBuilder<AssetChartDetails?>(
          initialData: bloc.chartDetails.value,
          stream: bloc.chartDetails,
          builder: (context, snapshot) {
            final details = snapshot.data;

            final isDataReady = (details?.isLoadingFinished ?? false);

            return isDataReady
                ? (details?.graphItemList.isNotEmpty ?? false)
                    ? _buildGraph(context, details!)
                    : Center(
                        child: PwText(
                          Strings.assetChartNoDataAvailable,
                          style: PwTextStyle.body,
                        ),
                      )
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

    final xFormatter = _formatterForGraphingData(details.value);
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

    final currentValue = graphList.first.price;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          height: 24,
          child: ValueListenableBuilder<AssetChartPoinData?>(
            valueListenable: changeNotifier,
            builder: (
              context,
              value,
              child,
            ) =>
                PriceChangeIndicator(value),
          ),
        ),
        Expanded(
          child: LineChart(
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
                enabled: true,
                handleBuiltInTouches: true,
                getTouchedSpotIndicator: _getTouchedSpotIndicator,
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions) {
                    return;
                  }
                  final spot = response?.lineBarSpots?.first;

                  if (spot == null || spot.spotIndex == 0) {
                    changeNotifier.value = null;
                  } else {
                    final price = spot.y;
                    final amountChanged =
                        ((price - currentValue) * 1000).toInt();
                    final percentChange =
                        (amountChanged / (currentValue * 1000).toInt()) / 100;

                    changeNotifier.value = AssetChartPoinData(
                      amountChanged / 1000,
                      percentChange,
                      DateTime.fromMillisecondsSinceEpoch(
                        spot.x.toInt(),
                      ),
                    );
                  }
                },
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.transparent,
                  tooltipPadding: const EdgeInsets.all(0),
                  tooltipMargin: 10,
                  getTooltipItems: (touchedBarSpots) => touchedBarSpots.map(
                    (e) {
                      return null;
                    },
                  ).toList(),
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
          ),
        ),
      ],
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

  intl.DateFormat _formatterForGraphingData(
    GraphingDataValue graphingDataValue,
  ) {
    String dateFormat;
    switch (graphingDataValue) {
      case GraphingDataValue.weekly:
      case GraphingDataValue.monthly:
        dateFormat = "MM/dd";
        break;
      case GraphingDataValue.yearly:
        dateFormat = "MM/dd/yyyy";
        break;
      default:
        dateFormat = "MM/dd HH:mm";
    }

    return intl.DateFormat(dateFormat);
  }

  List<TouchedSpotIndicatorData> _getTouchedSpotIndicator(
    LineChartBarData barData,
    List<int> indicators,
  ) {
    final dataLine = FlLine(color: graphColor, strokeWidth: 2);
    final dataPoint = FlDotCirclePainter(
      radius: 4,
      color: graphColor,
      strokeWidth: 2,
      strokeColor: graphColor,
    );
    final data = FlDotData(
      getDotPainter: (
        spot,
        percent,
        barData,
        index,
      ) {
        return dataPoint;
      },
    );

    return indicators
        .map((e) => TouchedSpotIndicatorData(
              dataLine,
              data,
            ))
        .toList();
  }
}

class PriceChangeIndicator extends StatelessWidget with PwColorMixin {
  PriceChangeIndicator(this.chartData, {Key? key}) : super(key: key);

  final AssetChartPoinData? chartData;

  @override
  PwColor? get color {
    final percentChanged = chartData?.percentChange ?? 0.0;

    if (percentChanged == 0.0) {
      return PwColor.neutral;
    } else if (percentChanged < 0.0) {
      return PwColor.negative;
    } else {
      return PwColor.positive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pwColor = this.color;
    final percentChanged = chartData?.percentChange ?? 0.0;
    final color = getColor(context);

    if (percentChanged == 0.00) {
      return PwText(
        "0.00",
        color: pwColor,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (percentChanged != 0.0)
          Icon(
            (percentChanged > 0.0) ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
          ),
        PwText(
          "\$${chartData!.price.toString()} (${percentChanged.toStringAsFixed(2)} %)",
          color: pwColor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
