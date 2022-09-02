import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final accountService = get<AccountService>();
    final strings = Strings.of(context);

    return Scaffold(
      appBar: PwAppBar(
        title: strings.transactionDetails,
        leadingIcon: PwIcons.back,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: Spacing.large),
          children: [
            DetailsItem(
              title: strings.tradeDetailsAccount,
              endChild: StreamBuilder<Account?>(
                initialData: accountService.events.selected.value,
                stream: accountService.events.selected,
                builder: (context, snapshot) {
                  final accountName = snapshot.data?.name ?? "";

                  return PwText(
                    accountName,
                    style: PwTextStyle.footnote,
                  );
                },
              ),
            ),
            PwListDivider(),
            DetailsItem.fromStrings(
              title: strings.tradeDetailsMessageType,
              value: transaction.messageType,
            ),
            PwListDivider(),
            DetailsItem.fromStrings(
              title: strings.tradeDetailsAssetName,
              value: transaction.displayDenom.isEmpty
                  ? strings.assetChartNotAvailable
                  : transaction.displayDenom,
            ),
            PwListDivider(),
            DetailsItem.fromStrings(
              title: strings.tradeDetailsTimeStamp,
              value: transaction.formattedTime,
            ),
            PwListDivider(),
            DetailsItem.withHash(
              title: strings.tradeDetailsFee,
              hashString: transaction.displayFee,
              context: context,
            ),
            PwListDivider(),
            DetailsItem.fromStrings(
              title: strings.tradeDetailsResult,
              value: transaction.status,
            ),
            PwListDivider(),
            DetailsItem.fromStrings(
              title: strings.tradeDetailsBlock,
              value: transaction.block.toString(),
            ),
            PwListDivider(),
            DetailsItem.withRowChildren(
              title: strings.tradeDetailsTransaction,
              children: [
                PwText(
                  abbreviateAddress(transaction.hash),
                  style: PwTextStyle.footnote,
                ),
                HorizontalSpacer.large(),
                GestureDetector(
                  onTap: () async {
                    final account = await accountService.getSelectedAccount();
                    String url;
                    switch (account?.coin) {
                      case Coin.testNet:
                        url =
                            'https://explorer.test.provenance.io/tx/${transaction.hash}';
                        break;
                      case Coin.mainNet:
                        url =
                            'https://explorer.provenance.io/tx/${transaction.hash}';
                        break;
                      default:
                        url = "";
                    }
                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: PwIcon(
                      PwIcons.newWindow,
                      color: Theme.of(context).colorScheme.neutralNeutral,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
