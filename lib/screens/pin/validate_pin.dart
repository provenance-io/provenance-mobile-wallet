import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/util/strings.dart';

class ValidatePin extends StatefulHookWidget {
  ValidatePin({this.code});

  final List<int>? code;

  @override
  State<StatefulWidget> createState() {
    return ValidatePinState();
  }
}

class ValidatePinState extends State<ValidatePin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 0.0,
        leading: IconButton(
          icon: PwIcon(
            PwIcons.back,
            size: 24,
            color: Theme.of(context).colorScheme.globalNeutral550,
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: PwText(
          Strings.enterPin,
          color: PwColor.globalNeutral550,
          style: PwTextStyle.h6,
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PinPad(
                subTitle: Strings.enterPinToVerifyYourIdentity,
                isConfirming: false,
                onFinish: _onFinish,
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
          error: Strings.yourPinDoesNotMatch,
        ),
      );
    } else {
      Navigator.of(context).pop(true);
    }
  }
}
