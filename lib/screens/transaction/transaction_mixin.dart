import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/transaction/transaction_field_title.dart';
import 'package:provenance_wallet/screens/transaction/transaction_field_value.dart';
import 'package:provenance_wallet/util/messages/message_field.dart';
import 'package:provenance_wallet/util/strings.dart';

mixin TransactionMessageMixin<T extends StatefulWidget> on State<T> {
  Widget createFieldGroupSliver(
    BuildContext context,
    List<TableRow> rows, [
    String? name,
  ]) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed(
        [
          if (name != null)
            Container(
              margin: EdgeInsets.only(
                top: Spacing.largeX4,
                left: Spacing.xxLarge,
              ),
              child: PwText(
                name,
                style: PwTextStyle.displayBody,
                color: PwColor.neutralNeutral,
              ),
            ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.largeX3,
            ),
            child: Table(
              columnWidths: const {
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

  TableRow createPlatformTableRow(String name, String? address) {
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
                text: name,
              ),
              if (address != null)
                TransactionFieldValue(
                  text: address,
                ),
            ],
          ),
        ),
      ],
    );
  }

  TableRow createMessageFieldRow(MessageField field) {
    return createFieldTableRow(field.key.name.capitalize(), field.value);
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
