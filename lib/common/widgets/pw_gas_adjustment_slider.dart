import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_gas_adjustment_thumb_shape.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/strings.dart';

class PwGasAdjustmentSlider extends StatefulWidget {
  const PwGasAdjustmentSlider({
    Key? key,
    this.padding,
    required this.title,
    required this.startingValue,
    this.min = 0,
    this.max = 5,
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
  State<StatefulWidget> createState() => _PwGasAdjustmentSliderState();
}

class _PwGasAdjustmentSliderState extends State<PwGasAdjustmentSlider> {
  late double _value;
  @override
  void initState() {
    _value = widget.startingValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  data: Theme.of(context)
                      .sliderTheme
                      .sliderThemeData
                      .copyWith(thumbShape: PwGasAdjustmentThumbShape()),
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
