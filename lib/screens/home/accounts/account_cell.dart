import 'package:flutter/services.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/accounts/account_item.dart';
import 'package:provenance_wallet/screens/home/accounts/accounts_bloc.dart';
import 'package:provenance_wallet/screens/home/accounts/rename_account_dialog.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_creation_status.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

enum MenuOperation {
  copy,
  rename,
  delete,
  viewInvite,
}

class AccountCell extends StatefulWidget {
  static const accountCellBackgroundKey = ValueKey("AccountCellBackground");
  static const accountCellMenuKey = ValueKey("AccountCellMenu");

  const AccountCell(
      {super.key, required this.isSelected, required this.account});

  final Account account;
  final bool isSelected;
  static final keyCopyAccountNumberButton =
      ValueKey('$AccountCell.copy_account_number_button');

  @override
  State<AccountCell> createState() => _AccountCellState();
}

class _AccountCellState extends State<AccountCell> {
  late Account _account;
  late final AccountsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _account = widget.account;
  }

  @override
  void didChangeDependencies() {
    _bloc = Provider.of<AccountsBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant AccountCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _account = widget.account;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final linkedAccount;

    if (_account is MultiAccount) {
      linkedAccount = (_account as MultiAccount).linkedAccount.name;
    } else {
      linkedAccount = null;
    }

    final isSelected = widget.isSelected;
    final background =
        isSelected ? colorScheme.secondary650 : colorScheme.neutral700;

    return Container(
      key: AccountCell.accountCellBackgroundKey,
      color: background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildAccountContainer(context, isSelected),
          if (linkedAccount != null)
            Divider(
                height: 1,
                thickness: 1,
                endIndent: 24,
                indent: 24,
                color: Theme.of(context).colorScheme.neutral750),
          if (linkedAccount != null)
            LinkedAccount(
              name: linkedAccount,
              isSelected: isSelected,
            ),
        ],
      ),
    );
  }

  Widget _buildAccountContainer(BuildContext context, bool isSelected) {
    final strings = Strings.of(context);
    final Coin coin;

    if (_account is BasicAccount) {
      coin = _account.coin!;
    } else if (_account is MultiAccount) {
      coin = _account.coin!;
    } else {
      throw Exception("Unknown account type");
    }

    return AccountContainer(
        name: _account.name,
        rows: [
          AccountTitleRow(
            name: _account.name,
            kind: _account.kind,
            isSelected: isSelected,
          ),
          if (_account.address != null)
            AccountDescriptionRow(address: _account.address!),
          AccountNetworkRow(
            coin: coin,
          ),
          if (_account.address == null)
            PwText(
              strings.accountStatusPending,
              style: PwTextStyle.bodySmall,
              color: PwColor.neutralNeutral,
            ),
        ],
        isSelected: isSelected,
        onShowMenu: () async {
          final operation = await _showMenu(
            context,
          );

          if (operation == null) {
            return;
          }
          _processMenuAction(context, operation);
        });
  }

  Future<void> _processMenuAction(
      BuildContext context, MenuOperation operation) async {
    final strings = Strings.of(context);
    switch (operation) {
      case MenuOperation.copy:
        await Clipboard.setData(
          ClipboardData(
            text: _account.address,
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
      case MenuOperation.rename:
        final text = await showDialog<String?>(
          barrierColor: Theme.of(context).colorScheme.neutral750,
          useSafeArea: true,
          barrierDismissible: false,
          context: context,
          builder: (context) => RenameAccountDialog(
            currentName: _account.name,
          ),
        );
        if (text != null) {
          await _bloc.renameAccount(_account, text);
        }
        break;
      case MenuOperation.delete:
        final dialogResult = await PwDialog.showConfirmation(
          context,
          message: strings.removeThisAccount,
          confirmText: strings.yes,
          cancelText: strings.cancel,
        );
        if (dialogResult) {
          _bloc.deleteAccount(_account);
        }
        break;
      case MenuOperation.viewInvite:
        Navigator.of(
          context,
          rootNavigator: true,
        ).push(
          MultiSigCreationStatus(
            accountId: _account.id,
          ).route(
            fullScreenDialog: true,
          ),
        );
        break;
    }
  }

  Future<MenuOperation?> _showMenu(BuildContext context) async {
    final List<MenuOperation> operations;
    if (_account is BasicAccount) {
      operations = <MenuOperation>[
        MenuOperation.rename,
        MenuOperation.copy,
        MenuOperation.delete
      ];
    } else {
      final isTransactable = _account is TransactableAccount;
      operations = <MenuOperation>[];
      if (isTransactable) {
        operations.add(MenuOperation.copy);
      }
      operations.add(MenuOperation.viewInvite);
      operations.add(MenuOperation.delete);
    }

    final strings = Strings.of(context);
    return showModalBottomSheet<MenuOperation>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return ListView.separated(
            key: AccountCell.accountCellMenuKey,
            shrinkWrap: true,
            itemCount: operations.length,
            separatorBuilder: (_, __) => PwListDivider(),
            itemBuilder: (contect, index) {
              final operation = operations[index];
              final String label;

              switch (operation) {
                case MenuOperation.copy:
                  label = strings.copyAccountAddress;
                  break;
                case MenuOperation.rename:
                  label = strings.rename;
                  break;
                case MenuOperation.delete:
                  label = strings.remove;
                  break;
                case MenuOperation.viewInvite:
                  label = strings.accountMenuItemViewInvite;
                  break;
              }

              return PwGreyButton(
                text: label,
                onPressed: () {
                  Navigator.of(context).pop(operation);
                },
              );
            });
      },
    );
  }
}
