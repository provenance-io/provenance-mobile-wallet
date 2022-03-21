import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/util/strings.dart';

class ValidatePin extends StatefulHookWidget {
  const ValidatePin({
    this.code,
    Key? key,
  }) : super(key: key);

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
      appBar: PwAppBar(
        leadingIconOnPress: () => Navigator.of(context).pop(false),
        title: Strings.enterPin,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PinPad(
                subTitle: Strings.enterPinToVerifyYourIdentity,
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
        useSafeArea: true,
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
