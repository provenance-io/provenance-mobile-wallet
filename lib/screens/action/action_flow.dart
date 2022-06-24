import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_screen.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';

class ActionFlow extends FlowBase {
  const ActionFlow({required this.account, Key? key}) : super(key: key);

  final Account account;

  @override
  State<StatefulWidget> createState() => ActionFlowState();
}

class ActionFlowState extends FlowBaseState {
  @override
  void initState() {
    super.initState();

    get.pushNewScope(scopeName: "ActionScope");
  }

  @override
  void dispose() {
    get.popScope();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flowTheme = theme.copyWith(
        tabBarTheme: theme.tabBarTheme.copyWith(
            indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.white)),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey));

    return Theme(
      data: flowTheme,
      child: super.build(context),
    );
  }

  @override
  Widget createStartPage() {
    if (!get.isRegistered<ActionListBloc>()) {
      get.registerLazySingleton<ActionListBloc>(() {
        return ActionListBloc()..init();
      });
    }

    return ActionListScreen();
  }
}
