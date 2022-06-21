import 'package:provenance_wallet/common/pw_design.dart';

class VotingBarChart extends StatelessWidget {
  const VotingBarChart({
    Key? key,
    required this.yes,
    required this.no,
    required this.noWithVeto,
    required this.abstain,
    required this.total,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Spacing.largeX3,
      vertical: Spacing.xLarge,
    ),
  }) : super(key: key);

  final double yes;
  final double no;
  final double noWithVeto;
  final double abstain;
  final double total;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final totalWidth =
        MediaQuery.of(context).size.width - padding.right - padding.left;
    return Padding(
      padding: padding,
      child: Stack(
        children: [
          Container(
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.neutral800,
              ),
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).colorScheme.neutral800,
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Yes
                if (yes > 0)
                  SizedBox(
                    width: yes / total * totalWidth,
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
                // No
                if (no > 0)
                  SizedBox(
                    width: no / total * totalWidth,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                // NoWithVeto
                if (noWithVeto > 0)
                  SizedBox(
                    width: noWithVeto / total * totalWidth,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.notice350,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context).colorScheme.notice350,
                      ),
                    ),
                  ),
                // Abstain
                if (abstain > 0)
                  SizedBox(
                    width: abstain / total * totalWidth,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.neutral600,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context).colorScheme.neutral600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
