import 'package:fl_chart/fl_chart.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_thumb_shape.dart';
import 'package:provenance_wallet/util/strings.dart';

class DepositSlider extends StatefulWidget {
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final String? label;
  final Color thumbColor;
  final double max;

  const DepositSlider({
    Key? key,
    required this.thumbColor,
    this.label,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.max = 100,
  }) : super(key: key);

  @override
  State<DepositSlider> createState() => _DepositSliderState();
}

class _DepositSliderState extends State<DepositSlider> {
  late double _value;
  @override
  void initState() {
    _value = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                    borderData: FlBorderData(
                      show: false,
                    ),
                    centerSpaceRadius: 150,
                    sections: [
                      PieChartSectionData(
                        showTitle: false,
                        color: colors.neutral700,
                        value: widget.max - _value,
                        radius: 10,
                      ),
                      PieChartSectionData(
                        color: widget.thumbColor,
                        value: _value,
                        showTitle: false,
                        radius: 10,
                      ),
                    ]),
                swapAnimationDuration: Duration.zero,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PwIcon(
                  PwIcons.hashLogo,
                  size: 24,
                  color: Theme.of(context).colorScheme.neutralNeutral,
                ),
                HorizontalSpacer.small(),
                PwText(
                  Strings.of(context).hashAmount(_value.toString()),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: PwTextStyle.footnote,
                ),
              ],
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PwText(
              0.toString(),
              style: PwTextStyle.footnote,
              textAlign: TextAlign.start,
              color: PwColor.neutral200,
            ),
            Expanded(
              child: SliderTheme(
                data: Theme.of(context).sliderTheme.sliderThemeData.copyWith(
                      valueIndicatorColor:
                          Theme.of(context).colorScheme.neutral700,
                      thumbColor: widget.thumbColor,
                      activeTrackColor: widget.thumbColor,
                      inactiveTrackColor:
                          Theme.of(context).colorScheme.neutral700,
                      thumbShape: PwThumbShape(),
                    ),
                child: Slider(
                  value: _value,
                  onChanged: (value) {
                    setState(() {
                      _value = value;
                      if (widget.onChanged != null) {
                        widget.onChanged!(_value);
                      }
                    });
                  },
                  onChangeStart: widget.onChangeStart,
                  onChangeEnd: widget.onChangeEnd,
                  divisions: widget.max.toInt(),
                  label: widget.label,
                  min: 0,
                  max: widget.max,
                ),
              ),
            ),
            PwText(
              widget.max.toInt().toString(),
              style: PwTextStyle.footnote,
              textAlign: TextAlign.start,
              color: PwColor.neutral200,
            ),
          ],
        ),
        VerticalSpacer.large()
      ],
    );
  }
}
