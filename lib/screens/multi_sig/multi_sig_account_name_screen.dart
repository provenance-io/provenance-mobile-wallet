import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigAccountNameScreen extends StatelessWidget {
  MultiSigAccountNameScreen({
    Key? key,
  }) : super(key: key);

  static const _screen = AddAccountScreen.multiSigConnect;

  final _bloc = get<AddAccountFlowBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.multiSigConnectTitle,
        leadingIcon: PwIcons.back,
        bottom: ProgressStepper(
          _bloc.getCurrentStep(_screen),
          _bloc.totalSteps,
        ),
      ),
      body: Container(),
    );
  }
}
