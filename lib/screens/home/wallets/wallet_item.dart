import 'package:flutter/services.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/extension/coin_extension.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/home/wallets/rename_wallet_dialog.dart';
import 'package:provenance_wallet/screens/home/wallets/wallets_bloc.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class WalletItem extends StatefulWidget {
  const WalletItem({
    Key? key,
    required WalletDetails wallet,
  })  : _initialWallet = wallet,
        super(key: key);

  final WalletDetails _initialWallet;

  @override
  State<WalletItem> createState() => _WalletItemState();
}

class _WalletItemState extends State<WalletItem> {
  final _subscriptions = CompositeSubscription();
  final _bloc = get<WalletsBloc>();

  late WalletDetails _wallet;

  @override
  void initState() {
    super.initState();

    _wallet = widget._initialWallet;
    _bloc.updated.listen((e) {
      setState(() {
        if (_wallet.id == e.id) {
          _wallet = e;
        }
      });
    }).addTo(_subscriptions);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final walletService = get<WalletService>();

    final isSelected = _wallet.id == walletService.events.selected.value?.id;

    return Container(
      color: isSelected ? colorScheme.secondary650 : colorScheme.neutral700,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: Spacing.xLarge,
                top: Spacing.large,
                bottom: Spacing.large,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.ltr,
                children: [
                  PwText(
                    _wallet.name,
                    style: PwTextStyle.bodyBold,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                  FutureBuilder<int?>(
                    future: get<WalletsBloc>().getAssetCount(_wallet),
                    builder: (context, snapshot) {
                      final numAssets = snapshot.data;

                      return PwText(
                        numAssets != null ? Strings.numAssets(numAssets) : '',
                        style: PwTextStyle.bodySmall,
                      );
                    },
                  ),
                  PwText(
                    _wallet.coin.displayName,
                    style: PwTextStyle.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showMenu(
              context,
              _wallet,
              isSelected,
            ),
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

  Future<void> _showMenu(
    BuildContext context,
    WalletDetails item,
    bool isSelected,
  ) async {
    final showAdvancedUI =
        await get<KeyValueService>().getBool(PrefKey.showAdvancedUI) ?? false;
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
            if (!isSelected) PwListDivider(),
            if (!isSelected)
              PwGreyButton(
                text: Strings.select,
                onPressed: () {
                  Navigator.of(context).pop(MenuOperation.select);
                },
              ),
            if (showAdvancedUI) PwListDivider(),
            if (showAdvancedUI)
              PwGreyButton(
                text: item.coin == Coin.mainNet
                    ? Strings.profileMenuUseTestnet
                    : Strings.profileMenuUseMainnet,
                onPressed: () {
                  Navigator.of(context).pop(MenuOperation.switchCoin);
                },
              ),
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

    final bloc = get<HomeBloc>();

    switch (result) {
      case MenuOperation.rename:
        final text = await showDialog<String?>(
          barrierColor: Theme.of(context).colorScheme.neutral750,
          useSafeArea: true,
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
          await get<WalletService>().removeWallet(id: item.id);
          final list = await get<WalletService>().getWallets();
          if (list.isEmpty) {
            get<LocalAuthHelper>().reset();
          }
        }
        break;
      case MenuOperation.select:
        await bloc.selectWallet(id: item.id);

        break;
      case MenuOperation.switchCoin:
        final coin = item.coin == Coin.mainNet ? Coin.testNet : Coin.mainNet;
        await bloc.setWalletCoin(id: item.id, coin: coin);
        break;
      default:
    }
  }
}

enum MenuOperation {
  copy,
  select,
  rename,
  delete,
  switchCoin,
}
