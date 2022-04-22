import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/enable_face_id_screen.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ConfirmPin extends StatefulHookWidget {
  const ConfirmPin(
    this.flowType, {
    required this.words,
    this.accountName,
    this.code,
    this.currentStep,
    this.numberOfSteps,
    Key? key,
  }) : super(key: key);

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
        bottom: ProgressStepper(
          widget.currentStep ?? 0,
          widget.numberOfSteps ?? 1,
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
                  subTitle: Strings.setAPinCodeToUnlockYourWallet,
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
        useSafeArea: true,
        context: context,
        builder: (context) => ErrorDialog(
          error: Strings.yourPinDoesNotMatchPleaseTryAgain,
        ),
      );
    } else {
      final biometryType = await get<CipherService>().getBiometryType();

      Navigator.of(context).push(EnableFaceIdScreen(
        biometryType: biometryType,
        accountName: widget.accountName,
        code: widget.code,
        words: widget.words,
        currentStep: (widget.currentStep ?? 0) + 1,
        numberOfSteps: widget.numberOfSteps,
      ).route());
    }
  }
}
