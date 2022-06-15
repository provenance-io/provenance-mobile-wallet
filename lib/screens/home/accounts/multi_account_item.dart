import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/screens/home/accounts/account_item.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_creation_status.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiAccountItem extends StatelessWidget {
  const MultiAccountItem({
    required MultiAccount account,
    Key? key,
  })  : _account = account,
        super(key: key);

  final MultiAccount _account;

  @override
  Widget build(BuildContext context) {
    const isSelected = false;

    return Container(
      color: isSelected
          ? Theme.of(context).colorScheme.secondary650
          : Theme.of(context).colorScheme.neutral700,
      child: Column(
        children: [
          AccountContainer(
            rows: [
              AccountTitleRow(
                name: _account.name,
                kind: _account.kind,
                isSelected: isSelected,
              ),
              if (_account.publicKey == null)
                PwText(
                  Strings.accountStatusPending,
                  style: PwTextStyle.bodySmall,
                  color: PwColor.neutralNeutral,
                ),
            ],
            isSelected: isSelected,
            onShowMenu: () => _showMenu(
              context,
              _account,
              isSelected,
            ),
          ),
          Divider(
              height: 1,
              thickness: 1,
              endIndent: 24,
              indent: 24,
              color: Theme.of(context).colorScheme.neutral750),
          LinkedAccount(
            name: _account.linkedAccount.name,
            isSelected: isSelected,
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
    var result = await showModalBottomSheet<MenuOperation>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PwGreyButton(
              text: Strings.accountMenuItemViewInvite,
              onPressed: () {
                Navigator.of(context).pop(MenuOperation.viewInvite);
              },
            ),
            PwGreyButton(
              text: Strings.remove,
              onPressed: () {
                Navigator.of(context).pop(MenuOperation.delete);
              },
            ),
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

    switch (result) {
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
}

enum MenuOperation {
  delete,
  viewInvite,
}
