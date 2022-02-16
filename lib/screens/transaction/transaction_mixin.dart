import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/transaction/transaction_field_title.dart';
import 'package:provenance_wallet/screens/transaction/transaction_field_value.dart';
import 'package:provenance_wallet/util/strings.dart';

mixin TransactionMessageMixin on Widget {
  Widget createFieldGroupSliver(BuildContext context, List<TableRow> rows) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed(
        [
          VerticalSpacer.xxLarge(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.largeX3,
            ),
            child: Table(
              columnWidths: {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Theme.of(context).colorScheme.darkGrey,
                ),
              ),
              children: rows,
            ),
          ),
        ],
      ),
    );
  }

  TableRow createPlatformTabeRow() {
    return TableRow(
      children: [
        Container(
          margin: EdgeInsets.symmetric(
            vertical: Spacing.large,
          ),
          child: TransactionFieldTitle(
            text: Strings.transactionFieldPlatform,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
            vertical: Spacing.large,
          ),
          child: Column(
            textDirection: TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TransactionFieldValue(
                text: Strings.transactionPlatformName,
              ),
              TransactionFieldValue(
                text: Strings.transactionPlatformAddress,
              ),
            ],
          ),
        ),
      ],
    );
  }

  TableRow createFieldTableRow(String title, String value) {
    return TableRow(
      children: [
        Container(
          margin: EdgeInsets.symmetric(
            vertical: Spacing.large,
          ),
          child: TransactionFieldTitle(
            text: title,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
            vertical: Spacing.large,
          ),
          child: TransactionFieldValue(
            text: value,
          ),
        ),
      ],
    );
  }
}
