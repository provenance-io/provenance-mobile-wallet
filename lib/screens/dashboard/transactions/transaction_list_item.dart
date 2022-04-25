import 'package:provenance_blockchain_wallet/common/pw_design.dart';
import 'package:provenance_blockchain_wallet/screens/dashboard/transactions/transaction_details_screen.dart';
import 'package:provenance_blockchain_wallet/services/models/transaction.dart';
import 'package:provenance_blockchain_wallet/util/assets.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    Key? key,
    required this.walletAddress,
    required this.item,
  }) : super(key: key);

  final String walletAddress;
  final Transaction item;
  final textDivider = " • ";
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(TransactionDetailsScreen(
          transaction: item,
        ).route());
      },
      child: Padding(
        padding: EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: Spacing.largeX3,
                height: Spacing.largeX3,
                child: Assets.getSvgPictureFrom(
                  denom: item.denom,
                  size: Spacing.largeX3,
                ),
              ),
              HorizontalSpacer.medium(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PwText(
                    item.displayDenom,
                    style: PwTextStyle.bodyBold,
                  ),
                  VerticalSpacer.xSmall(),
                  SizedBox(
                    width: 180,
                    child: PwText(
                      item.messageType + textDivider + item.formattedTime,
                      color: PwColor.neutral200,
                      style: PwTextStyle.footnote,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: PwIcon(
                  PwIcons.caret,
                  color: Theme.of(context).colorScheme.neutralNeutral,
                  size: 12.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
