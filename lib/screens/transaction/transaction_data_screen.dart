import 'package:provenance_blockchain_wallet/common/pw_design.dart';
import 'package:provenance_blockchain_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_blockchain_wallet/screens/transaction/transaction_data.dart';
import 'package:provenance_blockchain_wallet/util/strings.dart';

class TransactionDataScreen extends StatelessWidget {
  const TransactionDataScreen({
    required this.data,
    Key? key,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.neutral750,
      appBar: PwAppBar(
        title: Strings.transactionDataTitle,
        leadingIcon: PwIcons.back,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              VerticalSpacer.xxLarge(),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: Spacing.xxLarge,
                ),
                child: TransactionData(
                  data: data,
                ),
              ),
              VerticalSpacer.xxLarge(),
            ],
          ),
        ),
      ),
    );
  }
}
