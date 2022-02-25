import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/rename_wallet_dialog.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class WalletItem extends StatelessWidget {
  const WalletItem({
    Key? key,
    required this.item,
    required bool isSelected,
    required this.reload,
    required this.numAssets,
  })  : _isSelected = isSelected,
        super(key: key);

  final bool _isSelected;

  final WalletDetails item;
  final VoidCallback reload;
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
              var result = await showModalBottomSheet<MenuOperation>(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PwGreyButton(
                        text: Strings.copyWalletAddress,
                        onPressed: () {
                          Navigator.of(context).pop(MenuOperation.copy);
                        },
                      ),
                      PwListDivider(),
                      PwGreyButton(
                        text: Strings.rename,
                        onPressed: () {
                          Navigator.of(context).pop(MenuOperation.rename);
                        },
                      ),
                      PwListDivider(),
                      PwGreyButton(
                        text: Strings.remove,
                        onPressed: () {
                          Navigator.of(context).pop(MenuOperation.delete);
                        },
                      ),
                      PwListDivider(),
                      _isSelected
                          ? PwGreyButton(
                              text: Strings.resetWallets,
                              onPressed: () {
                                Navigator.of(context).pop(MenuOperation.reset);
                              },
                            )
                          : PwGreyButton(
                              text: Strings.select,
                              onPressed: () {
                                Navigator.of(context).pop(MenuOperation.select);
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

              final bloc = get<DashboardBloc>();

              switch (result) {
                case MenuOperation.rename:
                  final text = await showDialog<String?>(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => RenameWalletDialog(
                      currentName: item.name,
                    ),
                  );
                  if (text != null) {
                    await bloc.renameWallet(
                      id: item.id,
                      name: text,
                    );
                    reload.call();
                  }
                  break;
                case MenuOperation.copy:
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
                      backgroundColor: Theme.of(context).colorScheme.neutral700,
                    ),
                  );
                  break;
                case MenuOperation.delete:
                  final dialogResult = await PwDialog.showConfirmation(
                    context,
                    message: Strings.removeThisWallet,
                    confirmText: Strings.yes,
                    cancelText: Strings.cancel,
                  );
                  if (dialogResult) {
                    await bloc.removeWallet(id: item.id);
                    reload.call();
                  }
                  break;
                case MenuOperation.select:
                  await bloc.selectWallet(id: item.id);
                  reload.call();
                  break;
                case MenuOperation.reset:
                  await get<DashboardBloc>().resetWallets();
                  FlutterSecureStorage storage = FlutterSecureStorage();
                  await storage.deleteAll();

                  Navigator.of(context).popUntil((route) => route.isFirst);
                  break;
                default:
              }
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

enum MenuOperation {
  copy,
  select,
  rename,
  delete,
  reset,
}
