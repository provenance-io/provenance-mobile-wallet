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
      steps.add(Container(
        width: 61,
        height: 6,
        color: currentStep - 1 < i ? Color(0xFFC4C4C4) : Color(0xFF9E9E9E),
      ));
      steps.add(HorizontalSpacer.small());
    }

    steps.removeLast();

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: steps,
      ),
    );
  }
}
