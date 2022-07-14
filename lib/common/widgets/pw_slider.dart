import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_thumb_shape.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/strings.dart';

class PwSlider extends StatefulWidget {
  const PwSlider({
    Key? key,
    this.padding,
    required this.title,
    required this.startingValue,
    required this.min,
    required this.max,
    required this.onValueChanged,
    this.headerStyle = PwTextStyle.body,
  }) : super(key: key);

  final String title;
  final EdgeInsets? padding;
  final PwTextStyle headerStyle;
  final double startingValue;
  final double min;
  final double max;
  final Function(double) onValueChanged;

  @override
  State<StatefulWidget> createState() => _PwSliderState();
}

class _PwSliderState extends State<PwSlider> {
  late double _value;
  @override
  void initState() {
    _value = widget.startingValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        VerticalSpacer.largeX3(),
        PwText(
          widget.title,
          style: widget.headerStyle,
          textAlign: TextAlign.start,
        ),
        VerticalSpacer.largeX5(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PwText(
              "${widget.min.toInt()}",
              style: PwTextStyle.bodyBold,
              textAlign: TextAlign.start,
            ),
            Expanded(
              child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    showValueIndicator: ShowValueIndicator.always,
                    trackHeight: Spacing.xSmall,
                    trackShape: RoundedRectSliderTrackShape(),
                    activeTrackColor: theme.colorScheme.secondary350,
                    inactiveTrackColor: theme.colorScheme.neutral700,
                    overlayColor: theme.colorScheme.neutralNeutral,
                    thumbShape: PwThumbShape(),
                    thumbColor: theme.colorScheme.secondary350,
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 5.0),
                    tickMarkShape: RoundSliderTickMarkShape(),
                    activeTickMarkColor: Colors.transparent,
                    inactiveTickMarkColor: Colors.transparent,
                    valueIndicatorColor: theme.colorScheme.secondary350,
                    valueIndicatorTextStyle: theme.textTheme.footnote
                        .copyWith(color: theme.colorScheme.neutral800),
                  ),
                  child: Slider(
                    min: widget.min,
                    max: widget.max,
                    label: _value == defaultGasEstimate
                        ? "$_value ${Strings.stakingConfirmDefault}"
                        : "$_value",
                    value: _value,
                    divisions: 20,
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                        widget.onValueChanged(_value);
                      });
                    },
                  )),
            ),
            PwText(
              "${widget.max.toInt()}",
              style: PwTextStyle.bodyBold,
              textAlign: TextAlign.start,
            ),
          ],
        ),
        VerticalSpacer.large()
      ],
    );
  }
}
