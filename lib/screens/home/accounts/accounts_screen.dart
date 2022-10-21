import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/account/add_account_flow.dart';
import 'package:provenance_wallet/screens/account_type_screen.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/home/accounts/account_cell.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AccountsScreenState();
  }

  static final keySelectAccountButton =
      ValueKey('$AccountsScreen.select_account_button');
}

class AccountsScreenState extends State<AccountsScreen> {
  final _accountService = get<AccountService>();
  final _listKey = GlobalKey<AnimatedListState>();
  final _subscriptions = CompositeSubscription();

  List<Account>? _accounts;
  Account? _selected;
  Set<String>? _linkedIds;

  void _sort(List<Account>? accounts, Account? selected) {
    accounts?.sort((a, b) {
      if (b.id == selected?.id) {
        return 1;
      } else if (a.id == selected?.id) {
        return -1;
      } else {
        return 0;
      }
    });
  }

  Future<void> _load() async {
    Account? selected;
    List<Account>? accounts;
    Set<String>? linkedIds;

    try {
      selected = await _accountService.getSelectedAccount();
      accounts = await _accountService.getAccounts();
      linkedIds = accounts
          .whereType<MultiAccount>()
          .map((e) => e.linkedAccount.id)
          .toSet();

      _sort(accounts, selected);
    } finally {
      setState(() {
        _selected = selected;
        _accounts = accounts;
        _linkedIds = linkedIds;
      });
    }
  }

  @override
  void dispose() {
    _subscriptions.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _accountService.events.added.listen((e) {
      _accounts?.add(e);
      _sort(_accounts, _selected);

      if (e is MultiAccount) {
        _linkedIds?.add(e.id);
      }

      final index = _accounts?.indexWhere((i) => i.id == e.id);
      if (index != null) {
        _listKey.currentState?.insertItem(index);
      }
    }).addTo(_subscriptions);

    _accountService.events.removed.listen((e) {
      for (final account in e) {
        final index = _accounts?.indexWhere((i) => i.id == account.id);
        if (index != null) {
          _accounts?.removeAt(index);

          if (e is MultiAccount) {
            _linkedIds =
                _accounts?.whereType<MultiAccount>().map((e) => e.id).toSet();
          }

          _listKey.currentState?.removeItem(
            index,
            (context, animation) => _cellBuilder(
              context,
              animation,
              account,
            ),
          );
        }
      }
    }).addTo(_subscriptions);

    _accountService.events.selected.listen((e) {
      setState(() {
        _selected = e;
      });
    }).addTo(_subscriptions);

    _accountService.events.updated.listen((e) {
      final index = _accounts?.indexWhere((i) => i.id == e.id);
      if (index != null) {
        setState(() {
          _accounts?[index] = e;
        });
      }
    }).addTo(_subscriptions);

    _load();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = _accounts;

    return Scaffold(
      appBar: PwAppBar(
        title: Strings.of(context).accounts,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Stack(
              children: [
                accounts == null
                    ? Container()
                    : Container(
                        padding: EdgeInsets.only(
                          left: Spacing.large,
                          right: Spacing.large,
                          top: Spacing.medium,
                        ),
                        child: AnimatedList(
                          key: _listKey,
                          initialItemCount: accounts.length,
                          itemBuilder: (
                            context,
                            index,
                            animation,
                          ) {
                            final account = accounts[index];

                            return _cellBuilder(context, animation, account);
                          },
                        ),
                      ),
                Container(
                  alignment: Alignment.center,
                  child: accounts == null ? CircularProgressIndicator() : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Spacing.large,
              left: Spacing.large,
              right: Spacing.large,
            ),
            child: PwOutlinedButton(
              Strings.of(context).addAccount,
              onPressed: () {
                Navigator.of(context).push(
                  AddAccountFlow(
                    method: AddAccountMethod.create,
                    origin: AddAccountOrigin.accounts,
                  ).route(),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Spacing.large,
              left: Spacing.large,
              right: Spacing.large,
            ),
            child: PwTextButton.secondaryAction(
              context: context,
              text: Strings.of(context).recoverAccount,
              onPressed: () {
                Navigator.of(context).push(
                  AddAccountFlow(
                    method: AddAccountMethod.recover,
                    origin: AddAccountOrigin.accounts,
                  ).route(),
                );
              },
            ),
          ),
          VerticalSpacer.largeX3(),
        ],
      ),
    );
  }

  Widget _cellBuilder(
      BuildContext context, Animation<double> animation, Account account) {
    return SlideTransition(
      key: ValueKey(account.id),
      position: animation.drive(
        Tween(
          begin: Offset(1, 0),
          end: Offset(0, 0),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.only(
          bottom: 1,
        ),
        child: _getItem(account),
      ),
    );
  }

  Widget _getItem(Account account) {
    final isSelected = account.id == _selected?.id;
    final linkedIds = _linkedIds ?? {};

    return GestureDetector(
      key: AccountsScreen.keySelectAccountButton,
      child: AccountCell(
        account: account,
        isSelected: isSelected,
        isRemovable: !linkedIds.contains(account.id),
        key: ValueKey(account.id),
        onRename: _accountService.renameAccount,
        onRemove: ({
          required String id,
        }) =>
            _accountService.removeAccount(id: id),
      ),
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (isSelected ||
            (account is MultiAccount && account is! TransactableAccount)) {
          return;
        } else {
          await _accountService.selectAccount(id: account.id);
        }
      },
    );
  }
}
