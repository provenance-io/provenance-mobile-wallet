import 'package:flutter/services.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/network.dart';
import 'package:provenance_wallet/screens/home/accounts/account_item.dart';
import 'package:provenance_wallet/screens/home/accounts/faucet_screen.dart';
import 'package:provenance_wallet/screens/home/accounts/rename_account_dialog.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_creation_status.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

enum MenuOperation {
  copy,
  rename,
  delete,
  viewInvite,
  addHash,
  changeNetwork,
}

class AccountCell extends StatefulWidget {
  static const accountCellBackgroundKey = ValueKey("AccountCellBackground");
  static const accountCellMenuKey = ValueKey("AccountCellMenu");
  static final keyCopyAccountNumberButton =
      ValueKey('$AccountCell.copy_account_number_button');
  static final keyAddHashButton = ValueKey('$AccountCell.add_hash_button');

  const AccountCell({
    super.key,
    required this.isSelected,
    required this.isRemovable,
    required this.account,
    required this.onRename,
    required this.onRemove,
  });

  final Account account;
  final bool isSelected;
  final bool isRemovable;
  final Future<void> Function({
    required String id,
    required String name,
  }) onRename;
  final Future<void> Function({
    required String id,
  }) onRemove;

  @override
  State<AccountCell> createState() => _AccountCellState();
}

class _AccountCellState extends State<AccountCell> {
  late Account _account;

  @override
  void initState() {
    super.initState();
    _account = widget.account;
  }

  @override
  void didChangeDependencies() {
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

    final String? linkedAccount;

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
    final account = _account;
    final coin = account.coin;

    return AccountContainer(
        name: account.name,
        rows: [
          AccountTitleRow(
            name: account.name,
            kind: account.kind,
            isSelected: isSelected,
          ),
          if (account.address != null)
            AccountDescriptionRow(
              address: account.address!,
            ),
          if (coin != null)
            AccountNetworkRow(
              coin: coin,
            ),
          if (account.address == null)
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
          await widget.onRename(id: _account.id, name: text);
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
          widget.onRemove(id: _account.id);
        }
        break;
      case MenuOperation.viewInvite:
        Navigator.of(
          context,
          rootNavigator: true,
        ).push(
          MultiSigCreationStatus(
            accountId: _account.id,
            onDone: Navigator.of(context).pop,
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
              onHashAdd: bloc.load,
              address: _account.address!,
              coin: _account.coin!,
            ),
          ).route(),
        );
        break;
      case MenuOperation.changeNetwork:
        final network =
            _account.coin == Coin.testNet ? Network.mainNet : Network.testNet;
        get<AccountService>().selectNetwork(
          accountId: _account.id,
          network: network,
        );
        break;
    }
  }

  Future<MenuOperation?> _showMenu(BuildContext context) async {
    final account = _account;
    final List<MenuOperation> operations;

    if (account is BasicAccount) {
      operations = <MenuOperation>[
        MenuOperation.rename,
        MenuOperation.copy,
        if (account.linkedAccountIds.isEmpty) MenuOperation.changeNetwork,
        if (widget.isRemovable) MenuOperation.delete
      ];
    } else {
      final isTransactable = account is TransactableAccount;
      operations = <MenuOperation>[];
      if (isTransactable) {
        operations.add(MenuOperation.copy);
      }
      operations.add(MenuOperation.viewInvite);
      if (widget.isRemovable) operations.add(MenuOperation.delete);
    }

    if (account.coin == Coin.testNet) {
      operations.add(MenuOperation.addHash);
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
              Key? key;

              switch (operation) {
                case MenuOperation.copy:
                  label = strings.copyAccountAddress;
                  key = AccountCell.keyCopyAccountNumberButton;
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
                case MenuOperation.addHash:
                  label = strings.faucetScreenButtonTitle;
                  key = AccountCell.keyAddHashButton;
                  break;
                case MenuOperation.changeNetwork:
                  label = account.coin == Coin.testNet
                      ? strings.networkUseMainnet
                      : strings.networkUseTestnet;
                  break;
              }

              return PwGreyButton(
                key: key,
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
