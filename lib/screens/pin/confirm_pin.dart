import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/pw_theme.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/enable_face_id.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/util/strings.dart';

class ConfirmPin extends StatefulHookWidget {
  ConfirmPin(
    this.flowType, {
    required this.words,
    this.accountName,
    this.code,
    this.currentStep,
    this.numberOfSteps,
  });

  final List<String> words;
  final String? accountName;
  final List<int>? code;
  final int? currentStep;
  final int? numberOfSteps;
  final WalletAddImportType flowType;

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
        title: Strings.verifyPinCode,
        leadingIcon: PwIcons.back,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.provenanceNeutral750,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressStepper(
              widget.currentStep ?? 0,
              widget.numberOfSteps ?? 1,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 18),
                child: PinPad(
                  subTitle: Strings.setAPinCodeToUnlockYourWallet,
                  isConfirming: true,
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
    if (!eq(inputCodes, widget.code)) {
      await showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          error: Strings.yourPinDoesNotMatchPleaseTryAgain,
        ),
      );
    } else {
      Navigator.of(context).push(EnableFaceId(
        accountName: widget.accountName,
        code: widget.code,
        words: widget.words,
        currentStep: (widget.currentStep ?? 0) + 1,
        numberOfSteps: widget.numberOfSteps,
      ).route());
    }
  }
}
