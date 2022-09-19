import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal/pw_modal_screen.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_screen.dart';
import 'package:provenance_wallet/screens/transaction/transaction_confirm_screen.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/session_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/sign_action.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/messages/message_field_name.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provenance_wallet/util/type_registry.dart';
import 'package:provider/provider.dart';

class ActionFlow extends FlowBase {
  const ActionFlow({required this.account, Key? key}) : super(key: key);

  final Account account;

  @override
  State<StatefulWidget> createState() => ActionFlowState();
}

class ActionFlowState extends FlowBaseState implements ActionListNavigator {
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
    return Provider<ActionListBloc>(
        lazy: true,
        create: (context) {
          final bloc = ActionListBloc(
            this,
          );
          bloc.init();
          return bloc;
        },
        dispose: (_, bloc) {
          bloc.onDispose();
        },
        child: ActionListScreen());
  }

  /* ActionListNavigator */
  @override
  Future<bool> showApproveSession(SessionAction sessionRequestData) async {
    final name = sessionRequestData.data.clientMeta.name;

    return PwModalScreen.showConfirm(
      context: context,
      approveText: Strings.of(context).sessionApprove,
      declineText: Strings.of(context).sessionReject,
      title: Strings.of(context).dashboardConnectionRequestTitle,
      message:
          Strings.of(context).dashboardConnectionRequestAllowConnectionTo(name),
      icon: Image.asset(
        Assets.imagePaths.connectionRequest,
      ),
    );
  }

  @override
  Future<bool> showApproveSign(
      SignAction signRequest, ClientMeta clientMeta) async {
    return showGeneralDialog<bool>(
      context: context,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return TransactionConfirmScreen(
          kind: TransactionConfirmKind.approve,
          title: Strings.of(context).confirmSignTitle,
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
  Future<bool> showApproveTransaction({
    required List<proto.GeneratedMessage> messages,
    List<proto.Coin>? fees,
    ClientMeta? clientMeta,
  }) async {
    return showGeneralDialog<bool?>(
      context: context,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        final data = messages.map((message) {
          return <String, dynamic>{
            MessageFieldName.type: message.info_.qualifiedMessageName,
            ...message.toProto3Json(typeRegistry: provenanceTypes)
                as Map<String, dynamic>,
          };
        }).toList();

        return TransactionConfirmScreen(
          kind: TransactionConfirmKind.approve,
          title: Strings.of(context).confirmTransactionTitle,
          clientMeta: clientMeta,
          data: data,
          fees: fees,
        );
      },
    ).then((approved) => approved ?? false);
  }
}
