import 'package:intl/intl.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';

typedef AssetBarChartButtonDateChanged = Function(
  DateTime startDate,
  DateTime endDat,
);

final _dateFormatter = DateFormat("yyyy-MM-dd");

class AssetBarChartButton extends StatelessWidget {
  const AssetBarChartButton({
    Key? key,
    required this.dateTime,
    required this.onPressed,
  }) : super(key: key);
  final DateTime dateTime;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PwButton(
      child: PwText(_dateFormatter.format(dateTime)),
      onPressed: onPressed,
    );
  }
}

class AssetBarChartButtons extends StatelessWidget {
  const AssetBarChartButtons(
    this.startDate,
    this.endDate,
    this.dateChangedDelegate, {
    Key? key,
  }) : super(key: key);
  final DateTime startDate;
  final DateTime endDate;
  final AssetBarChartButtonDateChanged dateChangedDelegate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: AssetBarChartButton(
            key: ValueKey("StartDateButton"),
            dateTime: startDate,
            onPressed: () async {
              final value = await _onDateClicked(
                context,
                startDate,
                maxDate: endDate,
              );
              if (value == null) {
                return;
              }
              dateChangedDelegate(value, endDate);
            },
          ),
        ),
        HorizontalSpacer.small(),
        Flexible(
          flex: 1,
          child: AssetBarChartButton(
            key: ValueKey("EndDateButton"),
            dateTime: endDate,
            onPressed: () async {
              final value = await _onDateClicked(
                context,
                endDate,
                minDate: startDate,
              );
              if (value == null) {
                return;
              }
              dateChangedDelegate(startDate, value);
            },
          ),
        ),
      ],
    );
  }

  Future<DateTime?> _onDateClicked(
    BuildContext context,
    DateTime initialDate, {
    DateTime? maxDate,
    DateTime? minDate,
  }) {
    final lowestDate = DateTime(
      2008,
      00,
      01,
    );

    final topDate = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: lowestDate,
      lastDate: topDate,
      currentDate: initialDate,
      selectableDayPredicate: (newValue) {
        if (maxDate != null) {
          final diff = maxDate.difference(newValue);
          if (diff.isNegative || diff.inDays < 0) {
            return false;
          }
        }

        if (minDate != null) {
          final diff = newValue.difference(minDate);
          if (diff.isNegative || diff.inDays < 0) {
            return false;
          }
        }

        return true;
      },
      builder: (context, child) {
        final theme = Theme.of(context);
        // the default text color blends into the default background
        final colorTheme = theme.colorScheme.copyWith(onSurface: Colors.black);

        return Theme(
          data: theme.copyWith(
            colorScheme: colorTheme,
          ),
          child: child!,
        );
      },
    );
  }
}
