import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/asset/asset_chart_bloc.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class AssetChartPointData {
  AssetChartPointData(
    this.price,
    this.percentChange,
    this.amountChanged,
    this.timestamp,
  );

  final double price;
  final double amountChanged;
  final double percentChange;
  final DateTime timestamp;
}

typedef OnTouchPointChangedDelegate = void Function(
  AssetChartPointData? chardDataPoint,
);

class AssetBarChart extends StatelessWidget {
  const AssetBarChart(
    this.timeInterval, {
    Key? key,
    this.graphColor = Colors.blue,
    this.graphFillColor = Colors.white,
    this.labelColor = Colors.white,
    this.isCompact = false,
    required this.onTouchPointChanged,
  }) : super(key: key);

  final GraphingDataValue timeInterval;
  final Color graphColor;
  final Color? graphFillColor;
  final Color labelColor;
  final bool isCompact;
  final OnTouchPointChangedDelegate onTouchPointChanged;

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
      final x = item.timestamp.microsecondsSinceEpoch.toDouble();

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
      yFormatter.format(1050.02),
      yLabelAngle,
      textDirection,
      labelStyle,
    );

    final currentValue = graphList.first.price;

    final graphPointPainter = FlDotCirclePainter(
      color: graphColor,
      radius: 2,
    );

    if (minY == maxY) {
      minY *= .9;
      maxY *= 1.1;
    }

    checkToShowTitle(
      minValue,
      maxValue,
      sideTitles,
      appliedInterval,
      value,
    ) {
      final mod = value % appliedInterval;

      return mod == 0.0;
    }

    const microsecondsInAMinute = 1000000 * 60;
    double? interval;
    switch (details.value) {
      case GraphingDataValue.hourly:
        interval = microsecondsInAMinute * 5; //every 5 minutes
        break;
      case GraphingDataValue.daily:
        interval = microsecondsInAMinute * 60; //every hour
        break;
      case GraphingDataValue.weekly:
        interval = microsecondsInAMinute * 60 * 24 * 2; //every 2 days
        break;
      case GraphingDataValue.monthly:
        interval = microsecondsInAMinute * 60 * 24 * 7; //every week
        break;
      case GraphingDataValue.yearly:
        interval =
            microsecondsInAMinute * 60 * 24 * 30; //approximately every month
        break;
      default:
        interval = null;
    }

    return LineChart(
      LineChartData(
        maxY: maxY - minY,
        minY: 0,
        maxX: maxX - minX,
        minX: 0,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: false,
          bottomTitles: SideTitles(
            interval: interval,
            textAlign: TextAlign.center,
            showTitles: false,
            reservedSize: bottomSize.height,
            rotateAngle: xLabelAngle,
            getTextStyles: (context, value) => labelStyle,
            getTitles: (double value) {
              final timeStamp = DateTime.fromMicrosecondsSinceEpoch(
                (value + minX).toInt(),
              );

              return xFormatter.format(timeStamp);
            },
            checkToShowTitle: checkToShowTitle,
          ),
          leftTitles: SideTitles(
            showTitles: false,
            textAlign: TextAlign.center,
            reservedSize: leftSize.width,
            rotateAngle: yLabelAngle,
            getTextStyles: (context, value) => labelStyle,
            getTitles: (double value) => yFormatter.format(value + minY),
            checkToShowTitle: checkToShowTitle,
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
              onTouchPointChanged.call(null);

              return;
            }
            final spot = response?.lineBarSpots?.first;

            AssetChartPointData? pointData;

            if (!(spot == null || spot.spotIndex == 0)) {
              final price = spot.y + minY;
              final amountChanged = ((price - currentValue));
              final percentChange =
                  ((amountChanged / currentValue) * 1000) / 10;
              final timestamp = DateTime.fromMicrosecondsSinceEpoch(
                spot.x.toInt() + minX.toInt(),
              );

              pointData = AssetChartPointData(
                (price * 1000).toInt() / 1000,
                percentChange,
                (amountChanged * 1000).toInt() / 1000,
                timestamp,
              );
            }
            onTouchPointChanged.call(pointData);
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
            isStrokeCapRound: false,
            dotData: FlDotData(
              show: false,
              getDotPainter: (
                _,
                __,
                ___,
                ____,
              ) =>
                  graphPointPainter,
            ),
            preventCurveOverShooting: true,
            isCurved: true,
            colors: [graphColor],
            spots: graphList
                .map(
                  (element) => FlSpot(
                    (element.timestamp.microsecondsSinceEpoch - minX)
                        .toDouble(),
                    element.price - minY,
                  ),
                )
                .toList(),
            belowBarData: (graphFillColor == null)
                ? null
                : BarAreaData(
                    show: true,
                    gradientFrom: const Offset(0, 0),
                    gradientTo: const Offset(0, 1),
                    colors: [
                      graphColor,
                      graphFillColor!,
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
      radius: 0,
      color: graphColor,
      strokeWidth: 1,
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
