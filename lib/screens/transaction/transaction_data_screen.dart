import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/transaction/transaction_data.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/util/strings.dart';

class TransactionDataScreen extends StatelessWidget {
  const TransactionDataScreen({
    required this.request,
    Key? key,
  }) : super(key: key);

  final SendRequest request;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.provenanceNeutral750,
      appBar: PwAppBar(
        title: Strings.transactionDataTitle,
        leadingIcon: PwIcons.back,
      ),
      body: Column(
        children: [
          VerticalSpacer.xxLarge(),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: Spacing.xxLarge,
            ),
            child: TransactionData(
              request: request,
            ),
          ),
        ],
      ),
    );
  }
}
