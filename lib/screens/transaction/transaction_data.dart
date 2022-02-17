import 'dart:collection';

import 'package:pretty_json/pretty_json.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

class TransactionData extends StatefulWidget {
  const TransactionData({
    required this.request,
    Key? key,
  }) : super(key: key);

  final SendRequest request;

  @override
  _TransactionDataState createState() => _TransactionDataState();
}

class _TransactionDataState extends State<TransactionData> {
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
    return PwText(
      prettyData ?? '',
      color: PwColor.neutralNeutral,
    );
  }
}
