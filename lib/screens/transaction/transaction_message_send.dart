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
    const nHashPerHash = 1000000000; // 1 billion

    final generatedMessage = request.message;
    final fee = request.gasEstimate.fees / nHashPerHash;

    final message = generatedMessage as MsgSend;
    final fromAddress = message.fromAddress;
    final messageType = generatedMessage.info_.qualifiedMessageName;
    final toAddress = message.toAddress;
    var denom = message.amount.first.denom;
    var amount = message.amount.first.amount;

    if (denom == 'nhash') {
      denom = Strings.transactionDenomHash;
      amount = (int.parse(amount) / nHashPerHash).toString();
    }

    final rows = [
      createPlatformTabeRow(),
      createFieldTableRow(
        Strings.transactionFieldFromAddress,
        fromAddress.abbreviateAddress(),
      ),
      createFieldTableRow('Message Type', messageType),
      createFieldTableRow(
        Strings.transactionFieldFee,
        '$fee ${Strings.transactionDenomHash}',
      ),
      createFieldTableRow(
        Strings.transactionFieldToAddress,
        toAddress.abbreviateAddress(),
      ),
      createFieldTableRow(Strings.transactionFieldDenom, denom),
      createFieldTableRow(Strings.transactionFieldAmount, amount),
    ];

    return CustomScrollView(
      slivers: [
        createFieldGroupSliver(context, rows),
      ],
    );
  }
}
