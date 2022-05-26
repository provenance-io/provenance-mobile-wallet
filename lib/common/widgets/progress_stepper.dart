import 'package:provenance_wallet/common/pw_design.dart';

const _kProgressStepperSize = 3.0;

class ProgressStepper extends StatelessWidget implements PreferredSizeWidget {
  const ProgressStepper(
    this.currentStep,
    this.totalSteps, {
    Key? key,
    this.padding = const EdgeInsets.only(
      left: 20,
      right: 20,
      top: 12,
    ),
  }) : super(key: key);

  final int totalSteps;
  final int currentStep;
  final EdgeInsets padding;

  @override
  Size get preferredSize => Size.fromHeight(_kProgressStepperSize);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Stack(
        children: [
          Container(
            height: _kProgressStepperSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.neutral500,
              ),
              borderRadius: BorderRadius.circular(80),
              color: Theme.of(context).colorScheme.neutral500,
            ),
          ),
          FractionallySizedBox(
            widthFactor: currentStep / totalSteps,
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
