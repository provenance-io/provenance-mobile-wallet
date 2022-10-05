import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/change_pin_flow/change_pin_bloc.dart';
import 'package:provenance_wallet/screens/change_pin_flow/changed_pin_successfully_screen.dart';
import 'package:provenance_wallet/screens/change_pin_flow/confirm_new_pin_screen.dart';
import 'package:provenance_wallet/screens/change_pin_flow/create_new_pin_screen.dart';
import 'package:provenance_wallet/screens/change_pin_flow/enable_biometrics_screen.dart';
import 'package:provider/provider.dart';

class ChangePinFlow extends FlowBase {
  const ChangePinFlow(
    this._accountName, {
    Key? key,
  }) : super(key: key);
  final String _accountName;
  @override
  State<StatefulWidget> createState() => ChangePinFlowState();
}

class ChangePinFlowState extends FlowBaseState<ChangePinFlow>
    implements ChangePinBlocNavigator {
  @override
  Widget build(BuildContext context) {
    return Provider<ChangePinBloc>(
        lazy: true,
        create: (context) {
          final bloc = ChangePinBloc(
            widget._accountName,
            this,
          );

          return bloc;
        },
        dispose: (_, bloc) {
          bloc.onDispose();
        },
        child: super.build(context));
  }

  @override
  Widget createStartPage() => CreateNewPinScreen();

  @override
  Future<void> confirmPin() async {
    showPage((context) => ConfirmNewPinScreen());
  }

  @override
  Future<void> enableBiometrics() async {
    showPage((context) => EnableBiometricsScreen());
  }

  @override
  Future<void> pinUpdatedSuccessfully() async {
    showPage((context) => ChangedPinSuccessFullyScreen());
  }

  @override
  Future<void> endFlow() async {
    completeFlow(null);
  }
}
