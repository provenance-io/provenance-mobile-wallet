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
    this.pageController,
    Key? key,
  }) : super(key: key);

  final String requestId;
  final RemoteClientDetails clientDetails;
  final String? message;

  final List<Map<String, dynamic>>? data;
  final int? fees;
  final PageController? pageController;

  @override
  State<TransactionMessageDefault> createState() =>
      _TransactionMessageDefaultState(pageController);
}

class _TransactionMessageDefaultState extends State<TransactionMessageDefault>
    with TransactionMessageMixin {
  _TransactionMessageDefaultState(PageController? pageController)
      : _pageController = pageController ?? PageController() {
    _pageController.addListener(() {
      _pageIndexNotifier.value = _pageController.page?.round() ?? 0;
    });
  }

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

  final PageController _pageController;
  final ValueNotifier<int> _pageIndexNotifier = ValueNotifier(0);

  var slivers = <Widget>[];

  @override
  void dispose() {
    if (widget.pageController == null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // _buildSlivers();
  }

  @override
  void didUpdateWidget(covariant TransactionMessageDefault oldWidget) {
    super.didUpdateWidget(oldWidget);

    // _buildSlivers();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildHeaders(),
        SliverFillRemaining(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.data?.length ?? 0,
            itemBuilder: (context, index) {
              final map = widget.data![index];
              final group = _processor.findFields(map);
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

    final platformName = widget.clientDetails.name;
    final platformHost = widget.clientDetails.url?.host;

    headers.add(
      createFieldTableRow(
        Strings.transactionFieldPlatform,
        '$platformName\n$platformHost',
      ),
    );

    if (message != null) {
      headers.add(
        createFieldTableRow(Strings.transactionFieldMessage, message),
      );
    }

    if (fees != null) {
      final hashFees = fees / nHashPerHash;
      headers.add(
        createFieldTableRow(
          Strings.transactionFieldFee,
          '$hashFees ${Strings.transactionDenomHash}',
        ),
      );
    }

    return createFieldGroupSliver(
      context,
      headers,
    );
  }
}
