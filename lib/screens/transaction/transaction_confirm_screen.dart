import 'package:provenance_dart/proto.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/transaction/transaction_data_screen.dart';
import 'package:provenance_wallet/screens/transaction/transaction_message_default.dart';
import 'package:provenance_wallet/services/remote_client_details.dart';
import 'package:provenance_wallet/util/messages/message_field_name.dart';
import 'package:provenance_wallet/util/strings.dart';

typedef MessageBuilder = Widget Function(
  String requestId,
  RemoteClientDetails clientDetails,
  String? message,
  Map<String, dynamic>? data,
  GasEstimate? gasEstimate,
);

class TransactionConfirmScreen extends StatelessWidget {
  TransactionConfirmScreen({
    required this.title,
    required this.requestId,
    required this.clientDetails,
    this.subTitle,
    this.message,
    this.data,
    this.gasEstimate,
    Key? key,
  }) : super(key: key);
  final _builders = <Type, MessageBuilder>{
    // Add a builder to override a specific message type.
  };

  final String title;
  final String requestId;
  final RemoteClientDetails clientDetails;
  final String? subTitle;
  final String? message;
  final Map<String, dynamic>? data;
  final GasEstimate? gasEstimate;

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
            title,
            color: PwColor.neutralNeutral,
            style: PwTextStyle.subhead,
          ),
          automaticallyImplyLeading: false,
          actions: [
            if (data?.keys.contains(MessageFieldName.type) ?? false)
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
                        data: data!,
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
            if (subTitle != null)
              Container(
                margin: EdgeInsets.only(
                  left: Spacing.xxLarge,
                  top: Spacing.xxLarge,
                ),
                alignment: Alignment.centerLeft,
                child: PwText(
                  subTitle!,
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
    final builder = _builders[data.runtimeType];

    if (builder == null) {
      return TransactionMessageDefault(
        requestId: requestId,
        clientDetails: clientDetails,
        message: message,
        data: data,
        gasEstimate: gasEstimate,
      );
    }

    return builder.call(
      requestId,
      clientDetails,
      message,
      data,
      gasEstimate,
    );
  }
}
