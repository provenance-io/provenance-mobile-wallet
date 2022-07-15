import 'package:flutter/services.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/accounts/account_item.dart';
import 'package:provenance_wallet/screens/home/accounts/accounts_bloc.dart';
import 'package:provenance_wallet/screens/home/accounts/rename_account_dialog.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class BasicAccountItem extends StatefulWidget {
  const BasicAccountItem({
    Key? key,
    required BasicAccount account,
  })  : _initialAccount = account,
        super(key: key);

  final BasicAccount _initialAccount;

  @override
  State<BasicAccountItem> createState() => _BasicAccountItemState();
}

class _BasicAccountItemState extends State<BasicAccountItem> {
  final _subscriptions = CompositeSubscription();
  final _bloc = get<AccountsBloc>();

  late BasicAccount _account;

  @override
  void initState() {
    super.initState();

    _account = widget._initialAccount;
    _bloc.updated.listen((e) {
      setState(() {
        if (_account.id == e.id) {
          _account = e as BasicAccount;
        }
      });
    }).addTo(_subscriptions);
  }

  @override
  Widget build(BuildContext context) {
    final accountService = get<AccountService>();
    final isSelected = _account.id == accountService.events.selected.value?.id;
    final account = _account;

    return Container(
      color: isSelected
          ? Theme.of(context).colorScheme.secondary650
          : Theme.of(context).colorScheme.neutral700,
      child: AccountContainer(
        rows: [
          AccountTitleRow(
            name: account.name,
            kind: account.kind,
            isSelected: isSelected,
          ),
          AccountDescriptionRow(
            account: account,
            isSelected: isSelected,
          ),
          AccountNetworkRow(
            coin: account.publicKey.coin,
          ),
        ],
        isSelected: isSelected,
        onShowMenu: () => _showMenu(
          context,
          account,
          isSelected,
        ),
      ),
    );
  }

  Future<void> _showMenu(
    BuildContext context,
    BasicAccount item,
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
              text: Strings.copyAccountAddress,
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
            if (item.linkedAccountIds.isEmpty) PwListDivider(),
            if (item.linkedAccountIds.isEmpty)
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
                text: item.publicKey.coin == Coin.mainNet
                    ? Strings.profileMenuUseTestnet
                    : Strings.profileMenuUseMainnet,
                onPressed: () {
                  Navigator.of(context).pop(MenuOperation.switchCoin);
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

    final bloc = get<HomeBloc>();

    switch (result) {
      case MenuOperation.rename:
        final text = await showDialog<String?>(
          barrierColor: Theme.of(context).colorScheme.neutral750,
          useSafeArea: true,
          barrierDismissible: false,
          context: context,
          builder: (context) => RenameAccountDialog(
            currentName: item.name,
          ),
        );
        if (text != null) {
          await bloc.renameAccount(
            id: item.id,
            name: text,
          );
        }
        break;
      case MenuOperation.copy:
        await Clipboard.setData(
          ClipboardData(
            text: item.publicKey.address,
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
          message: Strings.removeThisAccount,
          confirmText: Strings.yes,
          cancelText: Strings.cancel,
        );
        if (dialogResult) {
          await get<AccountService>().removeAccount(id: item.id);
          final list = await get<AccountService>().getAccounts();
          if (list.isEmpty) {
            get<LocalAuthHelper>().reset();
          }
        }
        break;
      case MenuOperation.select:
        await bloc.selectAccount(id: item.id);

        break;
      case MenuOperation.switchCoin:
        final coin =
            item.publicKey.coin == Coin.mainNet ? Coin.testNet : Coin.mainNet;
        await bloc.setAccountCoin(id: item.id, coin: coin);
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
