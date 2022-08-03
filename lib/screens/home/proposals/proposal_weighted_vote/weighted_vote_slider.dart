import 'package:provenance_wallet/common/pw_design.dart';

class WeightedVoteSlider extends StatelessWidget {
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final String? label;
  final double value;
  final Color thumbColor;

  const WeightedVoteSlider({
    Key? key,
    required this.value,
    required this.thumbColor,
    this.label,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: Theme.of(context).sliderTheme.sliderThemeData.copyWith(
            valueIndicatorColor: Theme.of(context).colorScheme.neutral700,
            thumbColor: thumbColor,
            activeTrackColor: thumbColor,
            inactiveTrackColor: Theme.of(context).colorScheme.neutral700,
          ),
      child: Slider(
        value: value,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
        divisions: 100,
        label: label,
        min: 0,
        max: 100,
      ),
    );
  }
}
