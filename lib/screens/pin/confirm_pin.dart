import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/util/strings.dart';

class ConfirmPin extends StatefulHookWidget {
  const ConfirmPin({
    required this.bloc,
    required this.currentStep,
    required this.totalSteps,
    Key? key,
  }) : super(key: key);

  final AddAccountFlowBloc bloc;
  final int currentStep;
  final int totalSteps;

  @override
  State<StatefulWidget> createState() {
    return ConfirmPinState();
  }
}

class ConfirmPinState extends State<ConfirmPin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.of(context).verifyPinCode,
        leadingIcon: PwIcons.back,
        bottom: ProgressStepper(
          widget.currentStep,
          widget.totalSteps,
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 18),
                child: PinPad(
                  subTitle: Strings.of(context).setAPinCodeToUnlockYourAccount,
                  onFinish: _onFinish,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onFinish(List<int> inputCodes) async {
    Function eq = const ListEquality().equals;
    if (!eq(inputCodes, widget.bloc.pin)) {
      await showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) => ErrorDialog(
          error: Strings.of(context).yourPinDoesNotMatchPleaseTryAgain,
        ),
      );
    } else {
      await widget.bloc.submitConfirmPin();
    }
  }
}
