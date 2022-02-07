import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/network/models/transaction_response.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/trade_details_item.dart';
import 'package:provenance_wallet/util/strings.dart';

class TradeDetailsScreen extends StatelessWidget {
  TradeDetailsScreen({
    Key? key,
    required this.transaction,
    required this.walletName,
    required this.walletAddress,
  }) : super(key: key);

  final TransactionResponse transaction;
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
          child: FwText(
            Strings.tradeDetailsTitle,
            style: FwTextStyle.h6,
            color: FwColor.globalNeutral550,
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
            child: FwIcon(
              FwIcons.back,
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
              endChild: FwText(
                walletName,
                color: FwColor.globalNeutral500,
                style: FwTextStyle.m,
              ),
            ),
            _Divider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsTransaction,
              endChild: Container(
                child: Row(
                  children: [
                    FwText(
                      transaction.id ?? "",
                      style: FwTextStyle.m,
                      color: FwColor.globalNeutral600Black,
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
                        child: FwIcon(
                          FwIcons.new_window,
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
            _Divider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsFromAddress,
              endChild: // FIXME: Still don't know if transaction.address is to or from.
                  Container(
                child: Row(
                  children: [
                    FwText(
                      '${transaction.address?.substring(0, 3)}...${transaction.address?.substring(36)}',
                      style: FwTextStyle.m,
                      color: FwColor.globalNeutral600Black,
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: transaction.address),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: FwText(Strings.addressCopied)),
                        );
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        child: FwIcon(
                          FwIcons.copy,
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
            _Divider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsToAddress,
              endChild: // FIXME: Still don't know if transaction.address is to or from.
                  Container(
                child: Row(
                  children: [
                    FwText(
                      '${walletAddress.substring(0, 3)}...${walletAddress.substring(36)}',
                      style: FwTextStyle.m,
                      color: FwColor.globalNeutral600Black,
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: walletAddress),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: FwText(Strings.addressCopied)),
                        );
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        child: FwIcon(
                          FwIcons.copy,
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
            _Divider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsOrderType,
              endChild: FwText(
                transaction.type ?? "",
                color: FwColor.globalNeutral500,
                style: FwTextStyle.m,
              ),
            ),
            _Divider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsAmount,
              endChild: // FIXME: Need amount.
                  FwText(
                "20.000000000 Hash",
                color: FwColor.globalNeutral500,
                style: FwTextStyle.m,
              ),
            ),
            _Divider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsPricePerUnit,
              endChild: // FIXME: Need 'Price Per Unit'.
                  FwText(
                "0.020 USD",
                color: FwColor.globalNeutral500,
                style: FwTextStyle.m,
              ),
            ),
            _Divider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsTotalPurchase,
              endChild: // FIXME: Need 'Total Purchase Price'.
                  FwText(
                "50.00 USD",
                color: FwColor.globalNeutral500,
                style: FwTextStyle.m,
              ),
            ),
            _Divider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsFee,
              endChild: FwText(
                transaction.feeAmount ?? "",
                color: FwColor.globalNeutral500,
                style: FwTextStyle.m,
              ),
            ),
            _Divider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsTimeStamp,
              endChild: FwText(
                transaction.time ?? "",
                color: FwColor.globalNeutral500,
                style: FwTextStyle.m,
              ),
            ),
            _Divider(),
            TradeDetailsItem(
              title: Strings.tradeDetailsBlock,
              endChild: // FIXME: Need 'Block'.
                  FwText(
                "4831429",
                color: FwColor.globalNeutral500,
                style: FwTextStyle.m,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Theme.of(context).dividerColor,
    );
  }
}
