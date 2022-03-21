import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/wallets/rename_wallet_dialog.dart';
import 'package:provenance_wallet/screens/dashboard/wallets/wallets_bloc.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class WalletItem extends StatelessWidget {
  WalletItem({
    Key? key,
    required this.item,
    required bool isSelected,
    required this.numAssets,
  })  : _isSelected = isSelected,
        super(key: key);

  final bool _isSelected;
  final bloc = get<WalletsBloc>();
  final WalletDetails item;
  final int numAssets;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: _isSelected ? colorScheme.secondary650 : colorScheme.neutral700,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.xLarge,
              vertical: Spacing.large,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PwText(
                  item.name,
                  style: PwTextStyle.bodyBold,
                ),
                PwText(
                  Strings.numAssets(numAssets),
                  style: PwTextStyle.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              await showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PwGreyButton(
                        text: Strings.copyWalletAddress,
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(
                              text: item.address,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                Strings.addressCopied,
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.neutral700,
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                      PwListDivider(),
                      PwGreyButton(
                        text: Strings.rename,
                        onPressed: () async {
                          final text = await showDialog<String?>(
                            barrierColor:
                                Theme.of(context).colorScheme.neutral750,
                            useSafeArea: true,
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => RenameWalletDialog(
                              currentName: item.name,
                            ),
                          );

                          await bloc.renameWallet(
                            id: item.id,
                            name: text,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                      PwListDivider(),
                      PwGreyButton(
                        text: Strings.remove,
                        onPressed: () async {
                          final dialogResult = await PwDialog.showConfirmation(
                            context,
                            message: Strings.removeThisWallet,
                            confirmText: Strings.yes,
                            cancelText: Strings.cancel,
                          );
                          if (dialogResult) {
                            await bloc.removeWallet(item);
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                      PwListDivider(),
                      if (!_isSelected)
                        PwGreyButton(
                          text: Strings.select,
                          onPressed: () async {
                            await bloc.selectWallet(id: item.id);
                            Navigator.of(context).pop();
                          },
                        ),
                      PwListDivider(),
                      PwGreyButton(
                        enabled: false,
                        text: "",
                        // ignore: no-empty-block
                        onPressed: () {},
                      ),
                    ],
                  );
                },
              );
            },
            child: SizedBox(
              width: 60,
              height: 60,
              child: Center(
                child: PwIcon(
                  PwIcons.ellipsis,
                  color: Theme.of(context).colorScheme.neutralNeutral,
                ),
              ),
            ),
          ),
          VerticalSpacer.medium(),
        ],
      ),
    );
  }
}
