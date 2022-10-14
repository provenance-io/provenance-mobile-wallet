import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class ConfirmPinBloc {
  List<int> get pin;
  void submitConfirmPin();
}

class ConfirmPin extends StatefulHookWidget {
  const ConfirmPin({
    required ConfirmPinBloc bloc,
    Key? key,
  })  : _bloc = bloc,
        super(key: key);

  final ConfirmPinBloc _bloc;

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
    if (!eq(inputCodes, widget._bloc.pin)) {
      await showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) => ErrorDialog(
          error: Strings.of(context).yourPinDoesNotMatchPleaseTryAgain,
        ),
      );
    } else {
      widget._bloc.submitConfirmPin();
    }
  }
}
