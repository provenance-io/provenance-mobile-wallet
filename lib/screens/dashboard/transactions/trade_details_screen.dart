import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class TradeDetailsScreen extends StatelessWidget {
  const TradeDetailsScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final bloc = get<DashboardBloc>();

    return Scaffold(
      appBar: PwAppBar(
        title: Strings.tradeDetailsTitle,
        leadingIcon: PwIcons.back,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: ListView(
          children: [
            DetailsItem(
              title: Strings.tradeDetailsWallet,
              endChild: StreamBuilder<WalletDetails?>(
                initialData: bloc.selectedWallet.value,
                stream: bloc.selectedWallet,
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
                      // TODO: Change this url based on flavor.
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
              title: Strings.tradeDetailsFromAddress,
              endChild: Row(
                children: [
                  PwText(
                    transaction.senderAddress.abbreviateAddress(),
                    style: PwTextStyle.body,
                  ),
                  HorizontalSpacer.large(),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: transaction.senderAddress),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: PwText(Strings.addressCopied)),
                      );
                    },
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: PwIcon(
                        PwIcons.copy,
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
              title: Strings.tradeDetailsToAddress,
              endChild: StreamBuilder<WalletDetails?>(
                initialData: bloc.selectedWallet.value,
                stream: bloc.selectedWallet,
                builder: (context, snapshot) {
                  return Row(
                    children: [
                      PwText(
                        transaction.recipientAddress.abbreviateAddress(),
                        style: PwTextStyle.body,
                      ),
                      HorizontalSpacer.large(),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: transaction.recipientAddress),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: PwText(Strings.addressCopied)),
                          );
                        },
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: PwIcon(
                            PwIcons.copy,
                            color: Theme.of(context).colorScheme.neutralNeutral,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.tradeDetailsOrderType,
              endChild: PwText(
                transaction.denom,
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.tradeDetailsAmount,
              endChild: PwText(
                transaction.amount.toString(),
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.tradeDetailsPricePerUnit,
              endChild: // FIXME: Need 'Price Per Unit'.
                  PwText(
                "0.020 USD",
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.tradeDetailsTotalPurchase,
              endChild: // FIXME: Need 'Total Purchase Price'.
                  PwText(
                "50.00 USD",
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.tradeDetailsFee,
              endChild: PwText(
                transaction.txFee.toString(),
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.tradeDetailsTimeStamp,
              endChild: PwText(
                transaction.timestamp.toIso8601String(),
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.tradeDetailsBlock,
              endChild: PwText(
                transaction.block.toString(),
                style: PwTextStyle.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
