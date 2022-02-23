import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/transaction/transaction_data_screen.dart';
import 'package:provenance_wallet/screens/transaction/transaction_message_default.dart';
import 'package:provenance_wallet/screens/transaction/transaction_message_send.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/util/strings.dart';

typedef MessageBuilder = Widget Function(SendRequest request);

class TransactionConfirmScreen extends StatelessWidget {
  TransactionConfirmScreen({
    required this.request,
    Key? key,
  }) : super(key: key);
  final _builders = <Type, MessageBuilder>{
    MsgSend: (request) => TransactionMessageSend(request: request),
  };

  final SendRequest request;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.neutral750,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.neutral750,
          elevation: 0.0,
          centerTitle: true,
          title: PwText(
            Strings.transactionTitle,
            color: PwColor.neutralNeutral,
            style: PwTextStyle.subhead,
          ),
          automaticallyImplyLeading: false,
          actions: [
            if (_builders.containsKey(request.message.runtimeType))
              MaterialButton(
                onPressed: () {
                  showGeneralDialog(
                    context: context,
                    pageBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                    ) {
                      return TransactionDataScreen(
                        request: request,
                      );
                    },
                  );
                },
                child: PwText(
                  Strings.transactionDataButton,
                  color: PwColor.primaryP500,
                  style: PwTextStyle.body,
                ),
              ),
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VerticalSpacer.xxLarge(),
            Container(
              margin: EdgeInsets.only(
                left: Spacing.xxLarge,
              ),
              alignment: Alignment.centerLeft,
              child: PwText(
                Strings.transactionMessage,
                style: PwTextStyle.bodyBold,
              ),
            ),
            VerticalSpacer.xxLarge(),
            Expanded(
              child: _buildMessage(),
            ),
            Container(
              padding: EdgeInsets.only(
                left: Spacing.large,
                right: Spacing.large,
                bottom: Spacing.largeX4,
              ),
              color: Theme.of(context).colorScheme.neutral750,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PwTextButton.primaryAction(
                    context: context,
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    text: Strings.transactionApprove,
                  ),
                  VerticalSpacer.large(),
                  PwTextButton.secondaryAction(
                    context: context,
                    text: Strings.transactionDecline,
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage() {
    final builder = _builders[request.message.runtimeType];

    if (builder == null) {
      return TransactionMessageDefault(request: request);
    }

    return builder.call(request);
  }
}
