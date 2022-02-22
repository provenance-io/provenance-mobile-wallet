import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/trade_details_item.dart';
import 'package:provenance_wallet/util/strings.dart';

class TradeDetailsScreen extends StatelessWidget {
  TradeDetailsScreen({
    Key? key,
    required this.transaction,
    required this.walletName,
    required this.walletAddress,
  }) : super(key: key);

  final Transaction transaction;
  // FIXME: I want these two Strings to be part of a Bloc.
  final String walletName;
  final String walletAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 0.0,
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(
            top: 20,
          ),
          child: PwText(
            Strings.tradeDetailsTitle,
            style: PwTextStyle.h6,
            color: PwColor.globalNeutral550,
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(
            left: 24,
            top: 10,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: PwIcon(
              PwIcons.back,
              color: Theme.of(context).colorScheme.globalNeutral450,
              size: 24.0,
            ),
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.white,
        child: ListView(
          children: [
            TradeDetailsItem(
              title: Strings.tradeDetailsWallet,
              endChild: PwText(
                walletName,
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
            PwListDivider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsTransaction,
              endChild: Container(
                child: Row(
                  children: [
                    PwText(
                      transaction.id,
                      style: PwTextStyle.m,
                      color: PwColor.globalNeutral600Black,
                    ),
                    GestureDetector(
                      onTap: () async {
                        // FIXME: Navigate to explorer in the browser? Remove this ASAP.
                        await showDialog(
                          context: context,
                          builder: (context) => ErrorDialog(
                            error: "Coming Soon",
                          ),
                        );
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        child: PwIcon(
                          PwIcons.new_window,
                          color: Theme.of(context)
                              .colorScheme
                              .globalNeutral600Black,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PwListDivider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsFromAddress,
              endChild: // FIXME: Still don't know if transaction.address is to or from.
                  Container(
                child: Row(
                  children: [
                    PwText(
                      transaction.address.abbreviateAddress(),
                      style: PwTextStyle.m,
                      color: PwColor.globalNeutral600Black,
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: transaction.address),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: PwText(Strings.addressCopied)),
                        );
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        child: PwIcon(
                          PwIcons.copy,
                          color: Theme.of(context)
                              .colorScheme
                              .globalNeutral600Black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PwListDivider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsToAddress,
              endChild: // FIXME: Still don't know if transaction.address is to or from.
                  Container(
                child: Row(
                  children: [
                    PwText(
                      walletAddress.abbreviateAddress(),
                      style: PwTextStyle.m,
                      color: PwColor.globalNeutral600Black,
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: walletAddress),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: PwText(Strings.addressCopied)),
                        );
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        child: PwIcon(
                          PwIcons.copy,
                          color: Theme.of(context)
                              .colorScheme
                              .globalNeutral600Black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PwListDivider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsOrderType,
              endChild: PwText(
                transaction.type,
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
            PwListDivider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsAmount,
              endChild: // FIXME: Need amount.
                  PwText(
                "20.000000000 Hash",
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
            PwListDivider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsPricePerUnit,
              endChild: // FIXME: Need 'Price Per Unit'.
                  PwText(
                "0.020 USD",
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
            PwListDivider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsTotalPurchase,
              endChild: // FIXME: Need 'Total Purchase Price'.
                  PwText(
                "50.00 USD",
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
            PwListDivider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsFee,
              endChild: PwText(
                transaction.feeAmount,
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
            PwListDivider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsTimeStamp,
              endChild: PwText(
                transaction.time,
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
            PwListDivider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsBlock,
              endChild: // FIXME: Need 'Block'.
                  PwText(
                "4831429",
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
