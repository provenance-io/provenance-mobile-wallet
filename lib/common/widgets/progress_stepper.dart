import 'package:provenance_wallet/common/pw_design.dart';

class ProgressStepper extends StatelessWidget {
  const ProgressStepper(
    this.currentStep,
    this.numberOfSteps, {
    Key? key,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final int numberOfSteps;
  final int currentStep;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Stack(
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.neutral500,
              ),
              borderRadius: BorderRadius.circular(80),
              color: Theme.of(context).colorScheme.neutral500,
            ),
          ),
          FractionallySizedBox(
            widthFactor: currentStep / numberOfSteps,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary400,
                ),
                borderRadius: BorderRadius.circular(80),
                color: Theme.of(context).colorScheme.secondary400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
