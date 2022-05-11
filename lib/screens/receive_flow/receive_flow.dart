import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/receive_flow/receive/receive_bloc.dart';
import 'package:provenance_wallet/screens/receive_flow/receive/receive_screen.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/util/get.dart';

class ReceiveFlow extends FlowBase {
  const ReceiveFlow(
    this._accountDetails, {
    Key? key,
  }) : super(key: key);

  final AccountDetails _accountDetails;

  @override
  State<StatefulWidget> createState() => ReceiveFlowState();
}

class ReceiveFlowState extends FlowBaseState<ReceiveFlow>
    implements ReceiveNavigator {
  @override
  void initState() {
    super.initState();
    get.registerLazySingleton<ReceiveBloc>(() => ReceiveBloc(
          widget._accountDetails,
          this,
        ));
  }

  @override
  void dispose() {
    get.unregister<ReceiveBloc>();
    super.dispose();
  }

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
    return ReceiveScreen();
  }
}
