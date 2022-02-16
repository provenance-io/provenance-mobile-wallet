import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/transaction/transaction_mixin.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/util/strings.dart';

class TransactionMessageSend extends StatelessWidget
    with TransactionMessageMixin {
  const TransactionMessageSend({
    required this.request,
    Key? key,
  }) : super(key: key);

  final SendRequest request;

  @override
  Widget build(BuildContext context) {
    final generatedMessage = request.message;
    final fee = request.gasEstimate.fees;

    final message = generatedMessage as MsgSend;
    final fromAddress = message.fromAddress;
    final toAddress = message.toAddress;
    final denom = message.amount.first.denom;
    final amount = message.amount.first.amount;

    final rows = [
      createPlatformTabeRow(),
      createFieldTableRow(Strings.transactionFieldAmount, '$amount $denom'),
      createFieldTableRow(
        Strings.transactionFieldFee,
        '$fee ${Strings.transactionNanoHash}',
      ),
      createFieldTableRow(
        Strings.transactionFieldFromAddress,
        fromAddress.abbreviateAddress(),
      ),
      createFieldTableRow(
        Strings.transactionFieldToAddress,
        toAddress.abbreviateAddress(),
      ),
    ];

    return CustomScrollView(
      slivers: [
        createFieldGroupSliver(context, rows),
      ],
    );
  }
}
