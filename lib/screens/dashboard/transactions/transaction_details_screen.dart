import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final walletService = get<WalletService>();

    return Scaffold(
      appBar: PwAppBar(
        title: Strings.transactionDetails,
        leadingIcon: PwIcons.back,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: ListView(
          children: [
            DetailsItem(
              title: Strings.tradeDetailsWallet,
              endChild: StreamBuilder<WalletDetails?>(
                initialData: walletService.events.selected.value,
                stream: walletService.events.selected,
                builder: (context, snapshot) {
                  final walletName = snapshot.data?.name ?? "";

                  return PwText(
                    walletName,
                    style: PwTextStyle.body,
                  );
                },
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.tradeDetailsTransaction,
              endChild: Row(
                children: [
                  PwText(
                    transaction.hash.abbreviateAddress(),
                    style: PwTextStyle.body,
                  ),
                  HorizontalSpacer.large(),
                  GestureDetector(
                    onTap: () async {
                      // TODO: Change this url based on coin type.
                      final url =
                          'https://explorer.provenance.io/tx/${transaction.hash}';
                      if (await canLaunch(url)) {
                        await launch(url);
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
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Result",
              endChild: PwText(
                transaction.status,
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Message Type",
              endChild: PwText(
                "Send",
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.tradeDetailsFee,
              endChild: PwText(
                transaction.displayFee,
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.tradeDetailsTimeStamp,
              endChild: PwText(
                transaction.formattedTime,
                style: PwTextStyle.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
