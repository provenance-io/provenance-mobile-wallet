import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/trade_details_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

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
        color: Theme.of(context).colorScheme.provenanceNeutral750,
        child: ListView(
          children: [
            TradeDetailsItem(
              title: Strings.tradeDetailsWallet,
              endChild: StreamBuilder<String>(
                initialData: bloc.walletName.value,
                stream: bloc.walletName,
                builder: (context, snapshot) {
                  final walletName = snapshot.data ?? "";

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
            TradeDetailsItem(
              title: Strings.tradeDetailsTransaction,
              endChild: Row(
                children: [
                  PwText(
                    transaction.id.abbreviateAddress(),
                    style: PwTextStyle.body,
                  ),
                  HorizontalSpacer.large(),
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
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: PwIcon(
                        PwIcons.new_window,
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
            TradeDetailsItem(
              title: Strings.tradeDetailsFromAddress,
              endChild: // FIXME: Still don't know if transaction.address is to or from.
                  Row(
                children: [
                  PwText(
                    transaction.address.abbreviateAddress(),
                    style: PwTextStyle.body,
                  ),
                  HorizontalSpacer.large(),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: transaction.address),
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
            TradeDetailsItem(
              title: Strings.tradeDetailsToAddress,
              endChild: // FIXME: Still don't know if transaction.address is to or from.
                  StreamBuilder<String>(
                initialData: bloc.walletAddress.value,
                stream: bloc.walletAddress,
                builder: (context, snapshot) {
                  final walletAddress = snapshot.data ?? "";

                  return Row(
                    children: [
                      PwText(
                        walletAddress.abbreviateAddress(),
                        style: PwTextStyle.body,
                      ),
                      HorizontalSpacer.large(),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: walletAddress),
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
            TradeDetailsItem(
              title: Strings.tradeDetailsOrderType,
              endChild: PwText(
                transaction.type,
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            TradeDetailsItem(
              title: Strings.tradeDetailsAmount,
              endChild: // FIXME: Need amount.
                  PwText(
                "20.000000000 Hash",
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            TradeDetailsItem(
              title: Strings.tradeDetailsPricePerUnit,
              endChild: // FIXME: Need 'Price Per Unit'.
                  PwText(
                "0.020 USD",
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            TradeDetailsItem(
              title: Strings.tradeDetailsTotalPurchase,
              endChild: // FIXME: Need 'Total Purchase Price'.
                  PwText(
                "50.00 USD",
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            TradeDetailsItem(
              title: Strings.tradeDetailsFee,
              endChild: PwText(
                transaction.feeAmount,
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            TradeDetailsItem(
              title: Strings.tradeDetailsTimeStamp,
              endChild: PwText(
                transaction.time,
                color: PwColor.globalNeutral500,
                style: PwTextStyle.m,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
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
