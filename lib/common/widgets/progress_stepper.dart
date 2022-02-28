import 'package:provenance_wallet/common/pw_design.dart';

class ProgressStepper extends StatelessWidget {
  ProgressStepper(
    this.currentStep,
    this.numberOfSteps, {
    Key? key,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final int numberOfSteps;
  final int currentStep;
  final EdgeInsets padding;
// FIXME: Apply theme colors when possible.
  final Color secondary400 = Color(0xFF03B5B2);
  final Color neutral500 = Color(0xFF464B5D);

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
                color: neutral500,
              ),
              borderRadius: BorderRadius.circular(80),
              color: neutral500,
            ),
          ),
          FractionallySizedBox(
            widthFactor: currentStep / numberOfSteps,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                border: Border.all(
                  color: secondary400,
                ),
                borderRadius: BorderRadius.circular(80),
                color: secondary400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
