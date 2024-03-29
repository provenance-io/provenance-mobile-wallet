import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/receive_flow/receive/receive_bloc.dart';
import 'package:provenance_wallet/screens/receive_flow/receive/receive_screen.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provider/provider.dart';

class ReceiveFlow extends FlowBase {
  const ReceiveFlow(
    this._accountDetails, {
    Key? key,
  }) : super(key: key);

  final TransactableAccount _accountDetails;

  @override
  State<StatefulWidget> createState() => ReceiveFlowState();
}

class ReceiveFlowState extends FlowBaseState<ReceiveFlow>
    implements ReceiveNavigator {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const borderColor = Colors.white;
    final borderRadius = BorderRadius.circular(5);
    final borderSide = BorderSide(
      width: 1,
      color: borderColor,
    );

    final copy = theme.copyWith(
      canvasColor: Colors.grey,
      iconTheme: theme.iconTheme.copyWith(
        color: borderColor,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: borderSide,
        ),
        hintStyle: TextStyle(color: borderColor),
        suffixStyle: TextStyle(color: borderColor),
        counterStyle: TextStyle(color: borderColor),
      ),
    );

    return Theme(
      data: copy,
      child: super.build(context),
    );
  }

  @override
  Widget createStartPage() {
    return Provider<ReceiveBloc>(
      lazy: true,
      dispose: (_, bloc) => bloc.onDispose(),
      create: (context) {
        return ReceiveBloc(
          widget._accountDetails,
        );
      },
      child: ReceiveScreen(),
    );
  }
}
