import 'package:fl_chart/fl_chart.dart';
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
  final _bloc = get<WeightedVoteBloc>();
  String percentage = "0%";
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
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
                    centerSpaceRadius: 80,
                    sections: [
                      PieChartSectionData(
                        showTitle: false,
                        color: colors.neutral700,
                        value: _sharedPoints,
                        radius: 30,
                      ),
                      PieChartSectionData(
                        color: colors.primary500,
                        value: _currentValues[0],
                        showTitle: false,
                        radius: 30,
                      ),
                      PieChartSectionData(
                        color: colors.error,
                        value: _currentValues[1],
                        showTitle: false,
                        radius: 30,
                      ),
                      PieChartSectionData(
                        color: colors.notice350,
                        value: _currentValues[2],
                        showTitle: false,
                        radius: 30,
                      ),
                      PieChartSectionData(
                        color: colors.neutral550,
                        value: _currentValues[3],
                        showTitle: false,
                        radius: 30,
                      ),
                    ]),
                swapAnimationDuration: Duration.zero,
              ),
            ),
            Column(
              children: [
                PwText(Strings.proposalWeightedVoteVotingStatus),
                PwText(
                  percentage,
                  style: PwTextStyle.bodyBold,
                ),
              ],
            ),
          ],
        ),
        DetailsItem.alternateChild(
          padding: EdgeInsets.only(
            bottom: Spacing.small,
          ),
          title: Strings.proposalWeightedVoteVoteYes,
          endChild: PwText(
            "${_currentValues[0].toInt()}%",
            style: PwTextStyle.subhead,
          ),
        ),
        WeightedVoteSlider(
          thumbColor: colors.primary500,
          value: _currentValues[0],
          onChanged: (value) => updateCurrentValue(0, value.toInt()),
          onChangeEnd: (value) => _updateWeight(),
        ),
        VerticalSpacer.large(),
        DetailsItem.alternateChild(
          padding: EdgeInsets.only(
            bottom: Spacing.small,
          ),
          title: Strings.proposalWeightedVoteVoteNo,
          endChild: PwText(
            "${_currentValues[1].toInt()}%",
            style: PwTextStyle.subhead,
          ),
        ),
        WeightedVoteSlider(
          thumbColor: colors.error,
          value: _currentValues[1],
          onChanged: (value) => updateCurrentValue(1, value.toInt()),
          onChangeEnd: (value) => _updateWeight(),
        ),
        VerticalSpacer.large(),
        DetailsItem.alternateChild(
          padding: EdgeInsets.only(
            bottom: Spacing.small,
          ),
          title: Strings.proposalWeightedVoteVoteNoWithVeto,
          endChild: PwText(
            "${_currentValues[2].toInt()}%",
            style: PwTextStyle.subhead,
          ),
        ),
        WeightedVoteSlider(
          thumbColor: colors.notice350,
          value: _currentValues[2],
          onChanged: (value) => updateCurrentValue(2, value.toInt()),
          onChangeEnd: (value) => _updateWeight(),
        ),
        VerticalSpacer.large(),
        DetailsItem.alternateChild(
          padding: EdgeInsets.all(0),
          title: Strings.proposalWeightedVoteVoteAbstain,
          endChild: PwText(
            "${_currentValues[3].toInt()}%",
            style: PwTextStyle.subhead,
          ),
        ),
        WeightedVoteSlider(
          thumbColor: colors.neutral550,
          value: _currentValues[3],
          onChanged: (value) => updateCurrentValue(3, value.toInt()),
          onChangeEnd: (value) => _updateWeight(),
        ),
        VerticalSpacer.large(),
      ],
    );
  }

  void updateCurrentValue(int index, int newValue) {
    setState(() {
      final oldValue = _currentValues[index];
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

      var reducedValues =
          _currentValues.reduce((value, element) => value + element);
      _sharedPoints = 100 - reducedValues;
      percentage = "${reducedValues.toInt()}%";
    });
  }

  void _updateWeight() {
    _bloc.updateWeight(
      yesAmount: _currentValues[0],
      noAmount: _currentValues[1],
      noWithVetoAmount: _currentValues[2],
      abstainAmount: _currentValues[3],
    );
  }

  void updateSlider(int index, int newValue) {
    setState(
      () {
        final oldValue = _currentValues[index];
        final difference = newValue - oldValue;

        if (_sharedPoints == 0 && !difference.isNegative) {
          evenOutTotal(index, 1);
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
            return;
          }
        }
        if (_sharedPoints > 100) {
          // Rounding errors sometimes give me 101 or 102.
          _sharedPoints = 100;
        }
        var reducedValues =
            _currentValues.reduce((value, element) => value + element);
        _sharedPoints = 100 - reducedValues;
        percentage = "${reducedValues.toInt()}%";
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
    var reducedValues =
        _currentValues.reduce((value, element) => value + element);
    _sharedPoints = 100 - reducedValues;
    percentage = "${reducedValues.toInt()}%";
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
