import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_divider.dart';
import 'package:provenance_wallet/screens/transaction/transaction_data.dart';
import 'package:provenance_wallet/screens/transaction/transaction_mixin.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/util/strings.dart';

class TransactionMessageDefault extends StatelessWidget
    with TransactionMessageMixin {
  const TransactionMessageDefault({
    required this.request,
    Key? key,
  }) : super(key: key);

  final SendRequest request;

  @override
  Widget build(BuildContext context) {
    final fee = request.gasEstimate.fees;

    final rows = [
      createPlatformTabeRow(),
      createFieldTableRow(
        Strings.transactionFieldFee,
        '$fee ${Strings.transactionDenomHash}',
      ),
    ];

    return CustomScrollView(
      slivers: [
        createFieldGroupSliver(context, rows),
        SliverList(
          delegate: SliverChildListDelegate.fixed(
            [
              PwDivider(
                color: PwColor.neutral700,
                indent: Spacing.largeX3,
                endIndent: Spacing.largeX3,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.largeX3,
                  vertical: Spacing.large,
                ),
                child: TransactionData(
                  request: request,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
