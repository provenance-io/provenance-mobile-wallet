import 'dart:collection';

import 'package:pretty_json/pretty_json.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

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
  String? prettyData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final json = LinkedHashMap<String, dynamic>();
    json['@type'] = '/${widget.request.message.info_.qualifiedMessageName}';

    Object? jsonBody;
    try {
      jsonBody = widget.request.message.toProto3Json();
    } on Exception catch (e) {
      logError('Failed conversion to proto3 json');
      ErrorDialog.fromException(e);
    }

    if (jsonBody is Map<String, dynamic>) {
      json.addAll(jsonBody);
    }

    prettyData = prettyJson(json);
  }

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
          color: PwColor.white,
          style: PwTextStyle.subhead,
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: Spacing.xxLarge,
                  left: Spacing.largeX3,
                  right: Spacing.largeX3,
                  bottom: Spacing.xxLarge,
                ),
                child: PwText(
                  prettyData ?? '',
                  maxLines: 1000,
                ),
              ),
            ),
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
                      color: PwColor.white,
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
                      color: PwColor.white,
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
}
