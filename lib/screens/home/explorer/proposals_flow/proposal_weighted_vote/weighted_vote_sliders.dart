import 'package:provenance_wallet/common/pw_design.dart';

class WeightedVoteSliders extends StatefulWidget {
  const WeightedVoteSliders({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WeightedVoteSlidersState();
}

class _WeightedVoteSlidersState extends State<WeightedVoteSliders> {
  double _sharedPoints = 100;
  final List<double> _currentValues = [0, 0, 0, 0];
  final List<double> _startingValues = [0, 0, 0, 0];
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        PwText("${_sharedPoints.toInt()}"),
        WeightedVoteSlider(
          thumbColor: colors.primary550,
          value: _currentValues[0],
          label: "${_currentValues[0].toInt()}",
          onChanged: (value) => updateCurrentValue(0, value.toInt()),
          onChangeEnd: (value) => updateSlider(0, value.toInt()),
          onChangeStart: (value) => updateStartingValue(0, value.toInt()),
        ),
        WeightedVoteSlider(
          thumbColor: colors.error,
          value: _currentValues[1],
          label: "${_currentValues[1].toInt()}",
          onChanged: (value) => updateCurrentValue(1, value.toInt()),
          onChangeEnd: (value) => updateSlider(1, value.toInt()),
          onChangeStart: (value) => updateStartingValue(1, value.toInt()),
        ),
        WeightedVoteSlider(
          thumbColor: colors.notice350,
          value: _currentValues[2],
          label: "${_currentValues[2].toInt()}",
          onChanged: (value) => updateCurrentValue(2, value.toInt()),
          onChangeEnd: (value) => updateSlider(2, value.toInt()),
          onChangeStart: (value) => updateStartingValue(2, value.toInt()),
        ),
        WeightedVoteSlider(
          thumbColor: colors.neutral550,
          value: _currentValues[3],
          label: "${_currentValues[3].toInt()}",
          onChanged: (value) => updateCurrentValue(3, value.toInt()),
          onChangeEnd: (value) => updateSlider(3, value.toInt()),
          onChangeStart: (value) => updateStartingValue(3, value.toInt()),
        ),
      ],
    );
  }

  void updateCurrentValue(int index, int newValue) {
    setState(() {
      _currentValues[index] = newValue.toDouble();
    });
  }

  void updateStartingValue(int index, int newValue) {
    setState(() {
      _startingValues[index] = newValue.toDouble();
    });
  }

  void updateSlider(int index, int newValue) {
    setState(
      () {
        final oldValue = _startingValues[index];
        final difference = newValue - oldValue;

        if (_sharedPoints == 0 && !difference.isNegative) {
          evenOutTotal(index, difference.toInt());
          return;
        }

        if (difference <= _sharedPoints) {
          _currentValues[index] = newValue.toDouble();
          _sharedPoints -= difference;
        } else {
          final remainder = difference - _sharedPoints;
          if (remainder <= 0) {
            _currentValues[index] = _sharedPoints;
            _sharedPoints = 0;
            return;
          } else {
            _sharedPoints = 0;
            evenOutTotal(
              index,
              remainder.toInt(),
            );
          }
        }
        if (_sharedPoints > 100) {
          _sharedPoints = 100;
        }
      },
    );
  }

  void evenOutTotal(
    int ignoredIndex,
    int portionAmount,
  ) {
    if (portionAmount == 0) {
      return;
    }

    int amount = portionAmount;

    while (amount > 0) {
      if (ignoredIndex != 0 && didDecrementValueForIndex(0)) {
        amount--;
        if (amount == 0) {
          continue;
        }
      }

      if (ignoredIndex != 1 && didDecrementValueForIndex(1)) {
        amount--;
        if (amount == 0) {
          continue;
        }
      }

      if (ignoredIndex != 2 && didDecrementValueForIndex(2)) {
        amount--;
        if (amount == 0) {
          continue;
        }
      }

      if (ignoredIndex != 3 && didDecrementValueForIndex(3)) {
        amount--;
        if (amount == 0) {
          continue;
        }
      }
    }
  }

  bool didDecrementValueForIndex(int index) {
    final value = _currentValues[index].toInt();
    if (value == 0) {
      return false;
    }

    _currentValues[index]--;
    return true;
  }
}

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
      data: SliderTheme.of(context).copyWith(
        valueIndicatorColor: Theme.of(context).colorScheme.neutral700,
        thumbColor: thumbColor,
        activeTrackColor: thumbColor,
        inactiveTrackColor: thumbColor.withAlpha(100),
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
