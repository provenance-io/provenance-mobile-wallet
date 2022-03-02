import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/transaction/transaction_mixin.dart';
import 'package:provenance_wallet/services/models/remote_client_details.dart';
import 'package:provenance_wallet/util/messages/message_field.dart';
import 'package:provenance_wallet/util/messages/message_field_converters.dart';
import 'package:provenance_wallet/util/messages/message_field_group.dart';
import 'package:provenance_wallet/util/messages/message_field_name.dart';
import 'package:provenance_wallet/util/messages/message_field_processor.dart';
import 'package:provenance_wallet/util/strings.dart';

class TransactionMessageDefault extends StatefulWidget {
  const TransactionMessageDefault({
    required this.requestId,
    required this.clientDetails,
    this.message,
    this.data,
    this.fees,
    Key? key,
  }) : super(key: key);

  final String requestId;
  final RemoteClientDetails clientDetails;
  final String? message;

  final Map<String, dynamic>? data;
  final int? fees;

  @override
  State<TransactionMessageDefault> createState() =>
      _TransactionMessageDefaultState();
}

class _TransactionMessageDefaultState extends State<TransactionMessageDefault>
    with TransactionMessageMixin {
  final _processor = MessageFieldProcessor(
    converters: {
      MessageFieldName.fromAddress: convertAddress,
      MessageFieldName.toAddress: convertAddress,
      MessageFieldName.address: convertAddress,
      MessageFieldName.manager: convertAddress,
      MessageFieldName.delegatorAddress: convertAddress,
      MessageFieldName.validatorAddress: convertAddress,
      MessageFieldName.amount: convertAmount,
    },
  );

  var slivers = <Widget>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _buildSlivers();
  }

  @override
  void didUpdateWidget(covariant TransactionMessageDefault oldWidget) {
    super.didUpdateWidget(oldWidget);

    _buildSlivers();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: slivers,
    );
  }

  void _buildSlivers() {
    final fees = widget.fees;
    final message = widget.message;
    final data = widget.data;

    slivers = <Widget>[];

    final mainRows = <TableRow>[];

    final platformName = widget.clientDetails.name;
    final platformHost = widget.clientDetails.url?.host;

    mainRows.add(
      createFieldTableRow(
        Strings.transactionFieldPlatform,
        '$platformName\n$platformHost',
      ),
    );

    if (message != null) {
      mainRows.add(
        createFieldTableRow(Strings.transactionFieldMessage, message),
      );
    }

    if (fees != null) {
      final hashFees = fees / nHashPerHash;
      mainRows.add(
        createFieldTableRow(
          Strings.transactionFieldFee,
          '$hashFees ${Strings.transactionDenomHash}',
        ),
      );
    }

    final groupSlivers = <Widget>[];

    if (data != null) {
      final group = _processor.findFields(data);

      for (final field in group.fields) {
        if (field is MessageFieldGroup) {
          final rows = field.fields
              .whereType<MessageField>()
              .map((e) => createMessageFieldRow(e))
              .toList();
          groupSlivers.add(
            createFieldGroupSliver(
              context,
              rows,
              field.key.name.capitalize(),
            ),
          );
        } else if (field is MessageField) {
          mainRows.add(createMessageFieldRow(field));
        }
      }
    }

    slivers.add(createFieldGroupSliver(context, mainRows));
    slivers.addAll(groupSlivers);
  }
}
