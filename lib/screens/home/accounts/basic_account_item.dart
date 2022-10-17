import 'package:flutter/services.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/accounts/account_item.dart';
import 'package:provenance_wallet/screens/home/accounts/faucet_screen.dart';
import 'package:provenance_wallet/screens/home/accounts/rename_account_dialog.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class BasicAccountItem extends StatefulWidget {
  const BasicAccountItem({
    Key? key,
    required BasicAccount account,
  })  : _initialAccount = account,
        super(key: key);

  final BasicAccount _initialAccount;
  static final keyCopyAccountNumberButton =
      ValueKey('$BasicAccountItem.copy_account_number_button');

  @override
  State<BasicAccountItem> createState() => _BasicAccountItemState();
}

class _BasicAccountItemState extends State<BasicAccountItem> {
  CompositeSubscription _subscriptions = CompositeSubscription();
  final _accountService = get<AccountService>();
  late BasicAccount _account;
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _account = widget._initialAccount;

    _isSelected =
        _account.id == _accountService.events.selected.valueOrNull?.id;
  }

  @override
  void didChangeDependencies() {
    _subscriptions.cancel();

    final subscriptions = CompositeSubscription();

    _accountService.events.selected.listen((e) {
      final isSelected = _account.id == e?.id;
      if (isSelected != _isSelected) {
        setState(() {
          _isSelected = isSelected;
        });
      }
    }).addTo(subscriptions);

    _accountService.events.updated.listen((e) {
      setState(() {
        if (_account.id == e.id) {
          setState(() {
            _account = e as BasicAccount;
          });
        }
      });
    }).addTo(subscriptions);

    _subscriptions = subscriptions;
    super.didChangeDependencies();
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
        name: account.name,
        rows: [
          AccountTitleRow(
            name: account.name,
            kind: account.kind,
            isSelected: isSelected,
          ),
          AccountDescriptionRow(
            address: account.address,
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
    final strings = Strings.of(context);
    final accountService = get<AccountService>();

    var result = await showModalBottomSheet<MenuOperation>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return ListView(
          shrinkWrap: true,
          children: [
            PwGreyButton(
              key: BasicAccountItem.keyCopyAccountNumberButton,
              text: strings.copyAccountAddress,
              onPressed: () {
                Navigator.of(context).pop(MenuOperation.copy);
              },
            ),
            PwListDivider(),
            PwGreyButton(
              text: strings.rename,
              onPressed: () {
                Navigator.of(context).pop(MenuOperation.rename);
              },
            ),
            if (item.linkedAccountIds.isEmpty) PwListDivider(),
            if (item.linkedAccountIds.isEmpty)
              PwGreyButton(
                text: strings.remove,
                onPressed: () {
                  Navigator.of(context).pop(MenuOperation.delete);
                },
              ),
            if (item.coin == Coin.testNet) PwListDivider(),
            if (item.coin == Coin.testNet)
              PwGreyButton(
                text: strings.faucetScreenButtonTitle,
                onPressed: () {
                  Navigator.of(context).pop(MenuOperation.addHash);
                },
              ),
          ],
        );
      },
    );

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
          await accountService.renameAccount(id: item.id, name: text);
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
              strings.addressCopied,
            ),
            backgroundColor: Theme.of(context).colorScheme.neutral700,
          ),
        );
        break;
      case MenuOperation.delete:
        final dialogResult = await PwDialog.showConfirmation(
          context,
          message: strings.removeThisAccount,
          confirmText: strings.yes,
          cancelText: strings.cancel,
        );
        if (dialogResult) {
          await get<AccountService>().removeAccount(id: item.id);
          final list = await get<AccountService>().getAccounts();
          if (list.isEmpty) {
            get<LocalAuthHelper>().reset();
          }
        }
        break;
      case MenuOperation.addHash:
        final bloc = Provider.of<HomeBloc>(context, listen: false);

        Navigator.of(context).push(
          Provider.value(
            value: bloc,
            child: FaucetScreen(
              address: item.address,
              coin: item.coin,
            ),
          ).route(),
        );
        break;
      default:
    }
  }
}

enum MenuOperation {
  copy,
  rename,
  delete,
  addHash,
}
