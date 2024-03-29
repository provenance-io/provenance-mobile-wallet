import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/transaction/transaction_mixin.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/extensions/string_extensions.dart';
import 'package:provenance_wallet/util/messages/message_field.dart';
import 'package:provenance_wallet/util/messages/message_field_converters.dart';
import 'package:provenance_wallet/util/messages/message_field_group.dart';
import 'package:provenance_wallet/util/messages/message_field_name.dart';
import 'package:provenance_wallet/util/messages/message_field_processor.dart';
import 'package:provenance_wallet/util/strings.dart';

class TransactionMessageDefault extends StatefulWidget {
  const TransactionMessageDefault({
    this.clientMeta,
    this.message,
    this.data,
    this.fees,
    this.pageController,
    Key? key,
  }) : super(key: key);

  final ClientMeta? clientMeta;
  final String? message;

  final List<Map<String, dynamic>>? data;
  final List<proto.Coin>? fees;
  final PageController? pageController;

  @override
  State<TransactionMessageDefault> createState() =>
      _TransactionMessageDefaultState();
}

class _TransactionMessageDefaultState extends State<TransactionMessageDefault>
    with TransactionMessageMixin {
  late final PageController _pageController;
  final ValueNotifier<int> _pageIndexNotifier = ValueNotifier(0);

  var slivers = <Widget>[];

  @override
  void initState() {
    super.initState();

    _pageController = widget.pageController ?? PageController();
    _pageController.addListener(() {
      _pageIndexNotifier.value = _pageController.page?.round() ?? 0;
    });
  }

  @override
  void dispose() {
    if (widget.pageController == null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final processor = MessageFieldProcessor(
      transactionFieldTrue: Strings.of(context).transactionFieldTrue,
      transactionFieldFalse: Strings.of(context).transactionFieldFalse,
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
    return CustomScrollView(
      slivers: [
        _buildHeaders(),
        SliverFillRemaining(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.data?.length ?? 0,
            itemBuilder: (context, index) {
              final map = widget.data![index];
              final group = processor.findFields(map);
              final contents = <Widget>[];

              final ungrouped = group.fields
                  .whereType<MessageField>()
                  .map((field) => createMessageFieldRow(field))
                  .toList();

              contents.add(createFieldGroupSliver(
                context,
                ungrouped,
              ));

              contents.addAll(
                group.fields.whereType<MessageFieldGroup>().map((group) {
                  final rows = group.fields
                      .whereType<MessageField>()
                      .map((field) => createMessageFieldRow(field))
                      .toList();

                  return createFieldGroupSliver(
                    context,
                    rows,
                    group.key.name.capitalize(),
                  );
                }).toList(),
              );

              return CustomScrollView(slivers: contents);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaders() {
    final List<TableRow> headers = <TableRow>[];
    final fees = widget.fees;
    final message = widget.message;
    final clientMeta = widget.clientMeta;
    if (clientMeta != null) {
      final platformName = clientMeta.name;
      final platformHost = clientMeta.url?.host;

      headers.add(
        createFieldTableRow(
          Strings.of(context).transactionFieldPlatform,
          '$platformName\n$platformHost',
        ),
      );
    }

    if (message != null) {
      headers.add(
        createFieldTableRow(
            Strings.of(context).transactionFieldMessage, message),
      );
    }

    if (fees != null) {
      for (final coin in fees) {
        if (coin.denom == nHashDenom) {
          final nHash = int.tryParse(coin.amount);
          final fee = nHash == null
              ? '${coin.amount} ${coin.denom}'
              : '${nHash / nHashPerHash} ${Strings.transactionDenomHash}';

          headers.add(
            createFieldTableRow(
              Strings.of(context).transactionFieldFee,
              fee,
            ),
          );
        } else {
          headers.add(
            createFieldTableRow(
              Strings.of(context).transactionFieldFee,
              '${coin.amount} ${coin.denom}',
            ),
          );
        }
      }
    }

    return createFieldGroupSliver(
      context,
      headers,
    );
  }
}
