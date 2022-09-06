import 'package:provenance_wallet/common/pw_design.dart';

class SinglePercentageBarChart extends StatelessWidget {
  const SinglePercentageBarChart(
    this.current,
    this.total, {
    Key? key,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 0,
    ),
    this.color,
    required this.title,
    this.childStyle,
    this.showDecimal = true,
  }) : super(key: key);
  final String title;
  final double total;
  final double current;
  final EdgeInsets padding;
  final Color? color;
  final PwTextStyle? childStyle;
  final bool showDecimal;

  @override
  Widget build(BuildContext context) {
    final endValue = current != 0 && total != 0 ? ((current / total) * 100) : 0;
    double widthFactor = current != 0 ? current / total : 0;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.brightness_1,
              color: color ?? Theme.of(context).colorScheme.primary550,
              size: 8,
            ),
            HorizontalSpacer.xSmall(),
            PwText(
              title,
              style: PwTextStyle.footnote,
              color: PwColor.neutral200,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: PwText(
                  showDecimal
                      ? "${endValue.toStringAsFixed(2)}%"
                      : "${endValue.toInt()}%",
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: childStyle ?? PwTextStyle.bodyBold,
                ),
              ),
            ),
          ],
        ),
        VerticalSpacer.small(),
        Stack(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.neutral700,
                ),
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.neutral700,
              ),
            ),
            if (current <= total)
              FractionallySizedBox(
                widthFactor: widthFactor,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: color ?? Theme.of(context).colorScheme.primary550,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color: color ?? Theme.of(context).colorScheme.primary550,
                  ),
                ),
              ),
            if (current > total)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: color ?? Theme.of(context).colorScheme.primary550,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: color ?? Theme.of(context).colorScheme.primary550,
                ),
              ),
          ],
        ),
        VerticalSpacer.large(),
      ],
    );
  }
}
