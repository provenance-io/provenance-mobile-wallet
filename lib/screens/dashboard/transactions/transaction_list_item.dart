import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/trade_details_screen.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/util/strings.dart';

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
        Navigator.of(context).push(TradeDetailsScreen(
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
                child: PwIcon(
                  PwIcons.hashLogo,
                  color: Theme.of(context).colorScheme.neutralNeutral,
                  size: Spacing.largeX3,
                ),
              ),
              HorizontalSpacer.medium(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PwText(
                    item.denom.toUpperCase(),
                    style: PwTextStyle.bodyBold,
                  ),
                  VerticalSpacer.xSmall(),
                  Row(
                    children: [
                      PwText(
                        item.recipientAddress == walletAddress
                            ? Strings.buy
                            : Strings.sell,
                        color: PwColor.neutral200,
                        style: PwTextStyle.footnote,
                      ),
                      PwText(
                        textDivider,
                        color: PwColor.neutral200,
                        style: PwTextStyle.footnote,
                      ),
                      PwText(
                        item.formattedTimestamp,
                        color: PwColor.neutral200,
                        style: PwTextStyle.footnote,
                      ),
                    ],
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
