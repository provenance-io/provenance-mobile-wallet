import 'package:provenance_wallet/common/pw_design.dart';

class DepositBarChart extends StatelessWidget {
  const DepositBarChart(
    this.current,
    this.total, {
    Key? key,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Spacing.largeX3,
      vertical: Spacing.xLarge,
    ),
  }) : super(key: key);

  final int total;
  final int current;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Stack(
        children: [
          Container(
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.neutral700,
              ),
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).colorScheme.neutral700,
            ),
          ),
          FractionallySizedBox(
            widthFactor: current / total,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary550,
                ),
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.primary550,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
