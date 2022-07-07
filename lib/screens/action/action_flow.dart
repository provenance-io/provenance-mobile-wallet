import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal/pw_modal_screen.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_screen.dart';
import 'package:provenance_wallet/screens/transaction/transaction_confirm_screen.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/requests/send_request.dart';
import 'package:provenance_wallet/services/models/requests/sign_request.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/messages/message_field_name.dart';
import 'package:provenance_wallet/util/strings.dart';

class ActionFlow extends FlowBase {
  const ActionFlow({required this.account, Key? key}) : super(key: key);

  final Account account;

  @override
  State<StatefulWidget> createState() => ActionFlowState();
}

class ActionFlowState extends FlowBaseState implements ActionListNavigator {
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
        return ActionListBloc(this)..init();
      });
    }

    return ActionListScreen();
  }

  /* ActionListNavigator */
  @override
  Future<bool> showApproveSession(
      WalletConnectSessionRequestData sessionRequestData) async {
    final name = sessionRequestData.data.clientMeta.name;

    return PwModalScreen.showConfirm(
      context: context,
      approveText: Strings.sessionApprove,
      declineText: Strings.sessionReject,
      title: Strings.dashboardConnectionRequestTitle,
      message: Strings.dashboardConnectionRequestDetails(name),
      icon: Image.asset(
        Assets.imagePaths.connectionRequest,
      ),
    );
  }

  @override
  Future<bool> showApproveSign(
      SignRequest signRequest, ClientMeta clientMeta) async {
    return showGeneralDialog<bool>(
      context: context,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return TransactionConfirmScreen(
          kind: TransactionConfirmKind.approve,
          title: Strings.confirmSignTitle,
          requestId: signRequest.id,
          subTitle: signRequest.description,
          clientMeta: clientMeta,
          message: signRequest.message,
          data: [
            {
              MessageFieldName.address: signRequest.address,
            },
          ],
        );
      },
    ).then((approved) => approved ?? false);
  }

  @override
  Future<bool> showApproveTransaction(
      SendRequest sendRequest, ClientMeta clientMeta) async {
    return showGeneralDialog<bool?>(
      context: context,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        final messages = sendRequest.messages;
        final data = messages.map((message) {
          return <String, dynamic>{
            MessageFieldName.type: message.info_.qualifiedMessageName,
            ...message.toProto3Json() as Map<String, dynamic>,
          };
        }).toList();

        return TransactionConfirmScreen(
          kind: TransactionConfirmKind.approve,
          title: Strings.confirmTransactionTitle,
          requestId: sendRequest.id,
          clientMeta: clientMeta,
          data: data,
          fees: sendRequest.gasEstimate.feeCalculated,
        );
      },
    ).then((approved) => approved ?? false);
  }
}
