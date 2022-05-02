import 'package:intl/intl.dart' as intl;
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/asset/asset_bar_chart.dart';

class PriceChangeIndicator extends StatelessWidget with PwColorMixin {
  PriceChangeIndicator(this.chartData, {Key? key}) : super(key: key);

  final AssetChartPointData? chartData;

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
    final percentChanged = chartData?.percentChange;
    final color = getColor(context);

    if (percentChanged == null) {
      return PwText(
        "",
        color: pwColor,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    final format = intl.DateFormat("hh:mm a, MMM dd, yyyy");

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
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PwText(
              "\$${chartData!.price.toString()} (${percentChanged.toStringAsFixed(2)} %)",
              color: pwColor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: PwText(
                format.format(chartData!.timestamp),
                style: PwTextStyle.caption,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
