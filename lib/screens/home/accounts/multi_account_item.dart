import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/accounts/account_item.dart';
import 'package:provenance_wallet/screens/home/accounts/accounts_bloc.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_creation_status.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/strings.dart';
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
  final _subscriptions = CompositeSubscription();
  final _bloc = get<AccountsBloc>();
  final _accountService = get<AccountService>();
  late MultiAccount _account;
  late bool _isSelected;

  @override
  void initState() {
    super.initState();

    _account = widget._initialAccount;

    _bloc.updated.listen((e) {
      setState(() {
        if (_account.id == e.id) {
          setState(() {
            _account = e as MultiAccount;
          });
        }
      });
    }).addTo(_subscriptions);

    _isSelected =
        _account.id == _accountService.events.selected.valueOrNull?.id;
    _accountService.events.selected.listen((e) {
      final isSelected = _account.id == e?.id;
      if (isSelected != _isSelected) {
        setState(() {
          _isSelected = isSelected;
        });
      }
    });
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
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
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
            if (isTransactable && !isSelected) PwListDivider(),
            if (isTransactable && !isSelected)
              PwGreyButton(
                text: strings.select,
                onPressed: () {
                  Navigator.of(context).pop(MenuOperation.select);
                },
              ),
            PwListDivider(),
            PwGreyButton(
              enabled: false,
              text: '',
              // ignore: no-empty-block
              onPressed: () {},
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    final bloc = get<HomeBloc>();

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
      case MenuOperation.select:
        await bloc.selectAccount(id: item.id);

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
    }
  }
}

enum MenuOperation {
  copy,
  select,
  delete,
  viewInvite,
}
