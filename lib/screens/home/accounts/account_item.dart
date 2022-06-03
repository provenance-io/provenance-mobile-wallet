import 'package:flutter/services.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/extension/coin_extension.dart';
import 'package:provenance_wallet/screens/home/accounts/accounts_bloc.dart';
import 'package:provenance_wallet/screens/home/accounts/rename_account_dialog.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class AccountItem extends StatefulWidget {
  const AccountItem({
    Key? key,
    required AccountDetails account,
  })  : _initialAccount = account,
        super(key: key);

  final AccountDetails _initialAccount;

  @override
  State<AccountItem> createState() => _AccountItemState();
}

class _AccountItemState extends State<AccountItem> {
  final _subscriptions = CompositeSubscription();
  final _bloc = get<AccountsBloc>();

  late AccountDetails _account;

  @override
  void initState() {
    super.initState();

    _account = widget._initialAccount;
    _bloc.updated.listen((e) {
      setState(() {
        if (_account.id == e.id) {
          _account = e;
        }
      });
    }).addTo(_subscriptions);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accountService = get<AccountService>();

    final isSelected = _account.id == accountService.events.selected.value?.id;

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
                  Row(
                    children: [
                      PwText(
                        _account.name,
                        style: PwTextStyle.bodyBold,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: Spacing.large,
                        ),
                        child: Chip(
                          label: PwText(
                            _accountKindName(_account.kind),
                            style: PwTextStyle.footnote,
                            color: isSelected
                                ? PwColor.secondary350
                                : PwColor.neutral250,
                          ),
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.secondary700
                              : Theme.of(context).colorScheme.neutral600,
                        ),
                      ),
                    ],
                  ),
                  if (_account.isReady)
                    FutureBuilder<int?>(
                      future: get<AccountsBloc>().getAssetCount(_account),
                      builder: (context, snapshot) {
                        final numAssets = snapshot.data;

                        var text = '';
                        if (isSelected) {
                          text += Strings.selectedAccountLabel;
                          text += ' • ';
                        }

                        if (numAssets != null) {
                          text += Strings.numAssets(numAssets);
                        }

                        return Container(
                          margin: EdgeInsets.only(
                            top: 4,
                          ),
                          child: PwText(
                            text,
                            style: PwTextStyle.bodySmall,
                            color: PwColor.neutralNeutral,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                        );
                      },
                    ),
                  if (_account.isNotReady)
                    PwText(
                      Strings.accountStatusPending,
                      style: PwTextStyle.bodySmall,
                      color: PwColor.neutralNeutral,
                    ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 4,
                    ),
                    child: PwText(
                      _account.coin.displayName,
                      style: PwTextStyle.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showMenu(
              context,
              _account,
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

  String _accountKindName(AccountKind kind) {
    String name;
    switch (kind) {
      case AccountKind.single:
        name = Strings.accountKindSingle;
        break;
      case AccountKind.multi:
        name = Strings.accountKindMulti;
        break;
    }

    return name;
  }

  Future<void> _showMenu(
    BuildContext context,
    AccountDetails item,
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
            PwListDivider(),
            PwGreyButton(
              text: Strings.remove,
              onPressed: () {
                Navigator.of(context).pop(MenuOperation.delete);
              },
            ),
            if (!isSelected && item.isReady) PwListDivider(),
            if (!isSelected && item.isReady)
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
        final coin = item.coin == Coin.mainNet ? Coin.testNet : Coin.mainNet;
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
