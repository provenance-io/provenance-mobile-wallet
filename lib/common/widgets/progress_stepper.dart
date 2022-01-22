import 'package:flutter_tech_wallet/common/fw_design.dart';

class ProgressStepper extends StatelessWidget {
  ProgressStepper(
    this.currentStep,
    this.numberOfSteps, {
    this.padding = EdgeInsets.zero,
  });

  final int numberOfSteps;
  final int currentStep;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    List<Widget> steps = [];
    for (int i = 0; i < numberOfSteps; i++) {
      var color = currentStep - 1 < i ? Color(0xFFC4C4C4) : Color(0xFF9E9E9E);
      steps.add(
        Container(
          height: 6,
          width: 45,
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
            ),
            borderRadius: BorderRadius.circular(20),
            color: color,
          ),
        ),
      );
      if (currentStep != numberOfSteps - 1) {
        steps.add(HorizontalSpacer.small());
      }
    }

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: steps,
      ),
    );
  }
}
