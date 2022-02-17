import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/transaction/transaction_message_default.dart';
import 'package:provenance_wallet/screens/transaction/transaction_message_send.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/util/strings.dart';

typedef Widget MessageBuilder(SendRequest request);

class TransactionConfirmScreen extends StatefulWidget {
  TransactionConfirmScreen({
    required this.request,
    Key? key,
  }) : super(key: key);

  final SendRequest request;

  @override
  _TransactionConfirmScreenState createState() =>
      _TransactionConfirmScreenState();
}

class _TransactionConfirmScreenState extends State<TransactionConfirmScreen> {
  final _builders = <Type, MessageBuilder>{
    MsgSend: (request) => TransactionMessageSend(request: request),
  };

  var _isDataView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.provenanceNeutral750,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.provenanceNeutral750,
        elevation: 0.0,
        centerTitle: true,
        title: PwText(
          Strings.transaction,
          color: PwColor.neutralNeutral,
          style: PwTextStyle.subhead,
        ),
        automaticallyImplyLeading: false,
        actions: [
          if (_builders.containsKey(widget.request.message.runtimeType))
            MaterialButton(
              onPressed: () {
                setState(() {
                  _isDataView = !_isDataView;
                });
              },
              child: PwText(
                _isDataView
                    ? Strings.transactionListToggle
                    : Strings.transactionDataToggle,
                color: PwColor.primaryP500,
                style: PwTextStyle.body,
              ),
            ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _buildMessage(),
          ),
          Container(
            padding: EdgeInsets.only(
              left: Spacing.large,
              right: Spacing.large,
              bottom: Spacing.largeX6,
            ),
            color: Theme.of(context).colorScheme.provenanceNeutral750,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  color: Theme.of(context).colorScheme.primaryP500,
                  height: 50,
                  child: Container(
                    width: double.infinity,
                    child: PwText(
                      Strings.transactionApprove,
                      color: PwColor.neutralNeutral,
                      style: PwTextStyle.bodyBold,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                VerticalSpacer.large(),
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  height: 50,
                  child: Container(
                    width: double.infinity,
                    child: PwText(
                      Strings.transactionDecline,
                      color: PwColor.neutralNeutral,
                      style: PwTextStyle.bodyBold,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    final request = widget.request;
    final builder = _builders[request.message.runtimeType];

    if (_isDataView || builder == null) {
      return TransactionMessageDefault(request: request);
    }

    return builder.call(request);
  }
}
