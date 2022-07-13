import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote/weighted_vote_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposal_weighted_vote/weighted_vote_slider.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class WeightedVoteSliders extends StatefulWidget {
  const WeightedVoteSliders({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WeightedVoteSlidersState();
}

class _WeightedVoteSlidersState extends State<WeightedVoteSliders> {
  double _sharedPoints = 100;
  final List<double> _currentValues = [0, 0, 0, 0];
  final List<double> _startingValues = [0, 0, 0, 0];
  final _bloc = get<WeightedVoteBloc>();
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        DetailsItem.fromStrings(
          padding: EdgeInsets.only(
            top: Spacing.xLarge,
            left: Spacing.largeX3,
            right: Spacing.largeX3,
          ),
          title: Strings.proposalDetailsYes,
          value: "${_currentValues[0].toInt()}%",
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.large,
          ),
          child: WeightedVoteSlider(
            thumbColor: colors.primary550,
            value: _currentValues[0],
            label: "${_currentValues[0].toInt()}%",
            onChanged: (value) => updateCurrentValue(0, value.toInt()),
            onChangeEnd: (value) => updateSlider(0, value.toInt()),
            onChangeStart: (value) => updateStartingValue(0, value.toInt()),
          ),
        ),
        DetailsItem.fromStrings(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.largeX3,
          ),
          title: Strings.proposalDetailsNo,
          value: "${_currentValues[1].toInt()}%",
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.large,
          ),
          child: WeightedVoteSlider(
            thumbColor: colors.error,
            value: _currentValues[1],
            label: "${_currentValues[1].toInt()}%",
            onChanged: (value) => updateCurrentValue(1, value.toInt()),
            onChangeEnd: (value) => updateSlider(1, value.toInt()),
            onChangeStart: (value) => updateStartingValue(1, value.toInt()),
          ),
        ),
        DetailsItem.fromStrings(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.largeX3,
          ),
          title: Strings.proposalDetailsNoWithVeto,
          value: "${_currentValues[2].toInt()}%",
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.large,
          ),
          child: WeightedVoteSlider(
            thumbColor: colors.notice350,
            value: _currentValues[2],
            label: "${_currentValues[2].toInt()}%",
            onChanged: (value) => updateCurrentValue(2, value.toInt()),
            onChangeEnd: (value) => updateSlider(2, value.toInt()),
            onChangeStart: (value) => updateStartingValue(2, value.toInt()),
          ),
        ),
        DetailsItem.fromStrings(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.largeX3,
          ),
          title: Strings.proposalDetailsAbstain,
          value: "${_currentValues[3].toInt()}%",
        ),
        Padding(
          padding: EdgeInsets.only(
            left: Spacing.large,
            right: Spacing.large,
            bottom: Spacing.largeX3,
          ),
          child: WeightedVoteSlider(
            thumbColor: colors.neutral550,
            value: _currentValues[3],
            label: "${_currentValues[3].toInt()}%",
            onChanged: (value) => updateCurrentValue(3, value.toInt()),
            onChangeEnd: (value) => updateSlider(3, value.toInt()),
            onChangeStart: (value) => updateStartingValue(3, value.toInt()),
          ),
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
          _updateWeight();
        } else {
          final remainder = difference - _sharedPoints;
          if (remainder <= 0) {
            _currentValues[index] = _sharedPoints;
            _sharedPoints = 0;
            _updateWeight();
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
          // Rounding errors sometimes give me 101 or 102.
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
      _updateWeight();
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
    _updateWeight();
  }

  bool didDecrementValueForIndex(int index) {
    final value = _currentValues[index].toInt();
    if (value == 0) {
      return false;
    }

    _currentValues[index]--;
    return true;
  }

  void _updateWeight() {
    _bloc.updateWeight(
      yesAmount: _currentValues[0],
      noAmount: _currentValues[1],
      noWithVetoAmount: _currentValues[2],
      abstainAmount: _currentValues[3],
    );
  }
}
