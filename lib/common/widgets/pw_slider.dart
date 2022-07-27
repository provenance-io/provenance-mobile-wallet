import 'package:provenance_wallet/common/pw_design.dart';

class PwSlider extends StatefulWidget {
  const PwSlider({
    Key? key,
    this.padding,
    required this.title,
    required this.startingValue,
    required this.min,
    required this.max,
    required this.onValueChanged,
    this.createLabel = _defaultCreateLabel,
    this.headerStyle = PwTextStyle.body,
  }) : super(key: key);

  final String title;
  final EdgeInsets? padding;
  final PwTextStyle headerStyle;
  final double startingValue;
  final double min;
  final double max;
  final Function(double) createLabel;
  final Function(double) onValueChanged;

  @override
  State<StatefulWidget> createState() => _PwSliderState();

  static String _defaultCreateLabel(double value) {
    return "$value";
  }
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
      mainAxisSize: MainAxisSize.max,
      children: [
        VerticalSpacer.largeX3(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PwText(
              widget.title,
              style: widget.headerStyle,
              textAlign: TextAlign.start,
            ),
          ],
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
                    thumbShape: _ThumbShape(),
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
                    label: widget.createLabel(_value),
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

class _ThumbShape extends RoundSliderThumbShape {
  final _indicatorShape = const RectangularSliderValueIndicatorShape();
  final _innerShape = const RoundSliderThumbShape(enabledThumbRadius: 12);

  const _ThumbShape()
      : super(
          disabledThumbRadius: null,
          elevation: 1.0,
          enabledThumbRadius: 16,
          pressedElevation: 8.0,
        );

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);
    super.paint(
      context,
      center,
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
    );
    _indicatorShape.paint(context, center,
        activationAnimation: const AlwaysStoppedAnimation(1),
        enableAnimation: enableAnimation,
        isDiscrete: isDiscrete,
        labelPainter: labelPainter,
        parentBox: parentBox,
        sliderTheme: sliderTheme,
        textDirection: textDirection,
        value: value,
        textScaleFactor: textScaleFactor,
        sizeWithOverflow: sizeWithOverflow);
    _innerShape.paint(
      context,
      center,
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme.copyWith(thumbColor: Colors.white),
      textDirection: textDirection,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
    );
  }
}
