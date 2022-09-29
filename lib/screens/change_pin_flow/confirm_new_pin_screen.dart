import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/change_pin_flow/change_pin_bloc.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class ConfirmNewPinScreen extends StatefulHookWidget {
  const ConfirmNewPinScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ConfirmNewPinScreenState();
}

class ConfirmNewPinScreenState extends State<ConfirmNewPinScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.of(context).verifyPinCode,
        leadingIcon: PwIcons.back,
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
    Provider.of<ChangePinBloc>(context, listen: false)
        .enableBiometrics(inputCodes, context);
  }
}
