import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/util/strings.dart';

class CreatePin extends StatefulHookWidget {
  const CreatePin({
    required this.bloc,
    Key? key,
  }) : super(key: key);

  final AddAccountFlowBloc bloc;

  @override
  State<StatefulWidget> createState() {
    return CreatePinState();
  }
}

class CreatePinState extends State<CreatePin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.of(context).setPinCode,
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

  _onFinish(List<int> inputCodes) {
    widget.bloc.submitCreatePin(inputCodes);
  }
}
