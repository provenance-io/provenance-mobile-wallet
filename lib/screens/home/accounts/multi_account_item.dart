import 'package:flutter/services.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/accounts/account_item.dart';
import 'package:provenance_wallet/screens/home/accounts/accounts_bloc.dart';
import 'package:provenance_wallet/screens/home/accounts/faucet_screen.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_creation_status.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class MultiAccountItem extends StatefulWidget {
  const MultiAccountItem({
    required MultiAccount account,
    Key? key,
  })  : _initialAccount = account,
        super(key: key);

  final MultiAccount _initialAccount;

  @override
  State<MultiAccountItem> createState() => _MultiAccountItemState();
}

class _MultiAccountItemState extends State<MultiAccountItem> {
  CompositeSubscription _subscriptions = CompositeSubscription();
  final _accountService = get<AccountService>();
  late MultiAccount _account;
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
    final bloc = Provider.of<AccountsBloc>(context);
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

    bloc.updated.listen((e) {
      setState(() {
        if (_account.id == e.id) {
          setState(() {
            _account = e as MultiAccount;
          });
        }
      });
    }).addTo(subscriptions);
    _subscriptions = subscriptions;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _subscriptions.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _isSelected
          ? Theme.of(context).colorScheme.secondary650
          : Theme.of(context).colorScheme.neutral700,
      child: Column(
        children: [
          AccountContainer(
            name: _account.name,
            rows: [
              AccountTitleRow(
                name: widget._initialAccount.name,
                kind: widget._initialAccount.kind,
                isSelected: _isSelected,
              ),
              if (widget._initialAccount.address != null)
                AccountDescriptionRow(address: widget._initialAccount.address!),
              AccountNetworkRow(
                coin: _account.coin,
              ),
              if (widget._initialAccount.address == null)
                PwText(
                  Strings.of(context).accountStatusPending,
                  style: PwTextStyle.bodySmall,
                  color: PwColor.neutralNeutral,
                ),
            ],
            isSelected: _isSelected,
            onShowMenu: () => _showMenu(
              context,
              widget._initialAccount,
              _isSelected,
            ),
          ),
          Divider(
              height: 1,
              thickness: 1,
              endIndent: 24,
              indent: 24,
              color: Theme.of(context).colorScheme.neutral750),
          LinkedAccount(
            name: widget._initialAccount.linkedAccount.name,
            isSelected: _isSelected,
          ),
        ],
      ),
    );
  }

  Future<void> _showMenu(
    BuildContext context,
    MultiAccount item,
    bool isSelected,
  ) async {
    final strings = Strings.of(context);

    final isTransactable = item is TransactableAccount;

    var result = await showModalBottomSheet<MenuOperation>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return ListView(
          shrinkWrap: true,
          children: [
            if (isTransactable)
              PwGreyButton(
                text: strings.copyAccountAddress,
                onPressed: () {
                  Navigator.of(context).pop(MenuOperation.copy);
                },
              ),
            if (isTransactable) PwListDivider(),
            PwGreyButton(
              text: strings.accountMenuItemViewInvite,
              onPressed: () {
                Navigator.of(context).pop(MenuOperation.viewInvite);
              },
            ),
            PwListDivider(),
            PwGreyButton(
              text: strings.remove,
              onPressed: () {
                Navigator.of(context).pop(MenuOperation.delete);
              },
            ),
            if (item.coin == Coin.testNet) PwListDivider(),
            if (item.coin == Coin.testNet)
              PwGreyButton(
                text: "Add Hash",
                onPressed: () {
                  Navigator.of(context).pop(MenuOperation.addHash);
                },
              ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    switch (result) {
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
      case MenuOperation.copy:
        await Clipboard.setData(
          ClipboardData(
            text: item.address!,
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
      case MenuOperation.viewInvite:
        Navigator.of(
          context,
          rootNavigator: true,
        ).push(
          MultiSigCreationStatus(
            accountId: widget._initialAccount.id,
          ).route(
            fullScreenDialog: true,
          ),
        );
        break;
      case MenuOperation.addHash:
        final bloc = Provider.of<HomeBloc>(context, listen: false);

        Navigator.of(context).push(
          Provider.value(
            value: bloc,
            child: FaucetScreen(
              address: item.address!,
              coin: item.coin,
            ),
          ).route(),
        );
        break;
    }
  }
}

enum MenuOperation {
  copy,
  delete,
  viewInvite,
  addHash,
}
