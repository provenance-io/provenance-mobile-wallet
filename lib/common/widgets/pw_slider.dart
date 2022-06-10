import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DetailsItem(
          title: widget.title,
          endChild: PwText(
            '$_value',
            style: widget.headerStyle,
          ),
        ),
        Padding(
          padding: widget.padding ??
              EdgeInsets.symmetric(
                horizontal: Spacing.large,
              ),
          child: Slider(
            min: widget.min,
            max: widget.max,
            value: _value,
            divisions: 20,
            onChanged: (value) {
              setState(() {
                _value = value;
                widget.onValueChanged(_value);
              });
            },
          ),
        ),
      ],
    );
  }
}
