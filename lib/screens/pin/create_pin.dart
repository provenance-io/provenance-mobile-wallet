import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/screens/pin/confirm_pin.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/util/strings.dart';

class CreatePin extends StatefulHookWidget {
  CreatePin(
    this.flowType, {
    this.words,
    this.accountName,
    this.currentStep,
    this.numberOfSteps,
  });

  final List<String>? words;
  final String? accountName;
  final int? currentStep;
  final int? numberOfSteps;
  final WalletAddImportType flowType;

  @override
  State<StatefulWidget> createState() {
    return CreatePinState();
  }
}

class CreatePinState extends State<CreatePin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: FwIcon(
            FwIcons.back,
            size: 24,
            color: Color(0xFF3D4151),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: FwText(
          Strings.setYourPinCode,
          color: FwColor.globalNeutral550,
          style: FwTextStyle.h6,
        ),
      ),
      body: Container(
        color: Colors.white,
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
                  isConfirming: false,
                  onFinish: _onFinish,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onFinish(List<int> inputCodes) {
    Navigator.of(context).push(ConfirmPin(
      widget.flowType,
      accountName: widget.accountName,
      words: widget.words,
      code: inputCodes,
      numberOfSteps: widget.numberOfSteps,
      currentStep: widget.currentStep,
    ).route());
  }
}
