import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:rxdart/rxdart.dart';

class AccountsBlocState {
  const AccountsBlocState(this.selectedAccount, this.accounts);

  final List<Account> accounts;
  final String? selectedAccount;

  AccountsBlocState copyWith({
    List<Account>? accounts,
    String? selectedAccount,
  }) {
    return AccountsBlocState(
      selectedAccount ?? this.selectedAccount,
      accounts ?? this.accounts,
    );
  }
}

class AccountsBloc implements Disposable {
  AccountsBloc() {
    _accountService.events.added.listen(_onAdded).addTo(_subscriptions);
    _accountService.events.updated.listen(_onUpdated).addTo(_subscriptions);
    _accountService.events.selected.listen(_onSelected).addTo(_subscriptions);
    _accountService.events.removed.listen(_onRemoved).addTo(_subscriptions);
  }

  final _subscriptions = CompositeSubscription();
  final _accountService = get<AccountService>();
  final _loading = BehaviorSubject.seeded(false);
  final _stateSteam =
      BehaviorSubject.seeded(AccountsBlocState(null, <Account>[]));

  ValueStream<bool> get loading => _loading;

  ValueStream<AccountsBlocState> get accountsStream => _stateSteam.stream;

  void _setStreamState(AccountsBlocState state) {
    final accounts = state.accounts;
    final selectedId = state.selectedAccount;

    accounts.sort((a, b) {
      if (b.id == selectedId) {
        return 1;
      } else if (a.id == selectedId) {
        return -1;
      } else {
        return 0;
      }
    });

    _stateSteam.tryAdd(state.copyWith(accounts: accounts));
  }

  Future<void> load() async {
    _loading.tryAdd(true);

    try {
      await _reloadValues();
    } finally {
      _loading.tryAdd(false);
    }
  }

  Future selectAccount(Account account) async {
    await _accountService.selectAccount(id: account.id);
  }

  Account getAccountAtIndex(int index) {
    final state = _stateSteam.value;
    final accounts = List<Account>.from(state.accounts);
    final account = accounts[index];

    return account;
  }

  Future<void> renameAccount(Account account, String newName) async {
    await _accountService.renameAccount(id: account.id, name: newName);
  }

  Future<void> deleteAccount(Account account) async {
    await get<AccountService>().removeAccount(id: account.id);
    final list = await get<AccountService>().getAccounts();
    if (list.isEmpty) {
      get<LocalAuthHelper>().reset();
    }
  }

  @override
  FutureOr onDispose() {
    _subscriptions.dispose();
    _stateSteam.close();
    _loading.close();
  }

  Future<void> _reloadValues() async {
    final results = await Future.wait([
      _accountService.getSelectedAccount(),
      _accountService.getAccounts()
    ]);

    final newState = AccountsBlocState(
        (results[0] as Account?)?.id, results[1] as List<Account>);

    _setStreamState(newState);
  }

  Future<void> _onAdded(Account account) async {
    _reloadValues();
  }

  void _onRemoved(List<Account> removedAccounts) {
    _reloadValues();
  }

  void _onUpdated(Account account) {
    _reloadValues();
  }

  void _onSelected(Account? account) {
    _reloadValues();
  }
}
