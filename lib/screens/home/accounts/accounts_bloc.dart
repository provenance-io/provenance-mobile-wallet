import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class AccountsBloc implements Disposable {
  AccountsBloc() {
    _accountService.events.added.listen(_onAdded).addTo(_subscriptions);
    _accountService.events.updated.listen(_onUpdated).addTo(_subscriptions);
    _accountService.events.selected.listen(_onSelected).addTo(_subscriptions);
  }

  final _subscriptions = CompositeSubscription();
  final _accountService = get<AccountService>();
  final _assetService = get<AssetService>();
  final _count = BehaviorSubject.seeded(0);

  final _updated = PublishSubject<Account>();
  final _insert = PublishSubject<int>();
  final _loading = BehaviorSubject.seeded(false);

  Completer? _completer;
  var _accounts = <Account>[];
  final _assetCounts = <String, int>{};

  ValueStream<int> get count => _count;
  Stream<Account> get updated => _updated;
  Stream<int> get insert => _insert;
  ValueStream<bool> get loading => _loading;

  Future<void> load() async {
    var completer = _completer;
    if (completer != null) {
      await completer.future;
    }

    completer = Completer();
    _completer = completer;

    _loading.tryAdd(true);

    try {
      final selectedAccount = await _accountService.getSelectedAccount();
      var details = await _accountService.getAccounts();
      details.sort((a, b) {
        if (b.id == selectedAccount?.id) {
          return 1;
        } else if (a.id == selectedAccount?.id) {
          return -1;
        } else {
          return 0;
        }
      });

      _accounts = details;
      _count.tryAdd(_accounts.length);
    } finally {
      completer.complete();
      _loading.tryAdd(false);
    }
  }

  Account getAccountAtIndex(int index) {
    final account = _accounts[index];

    return account;
  }

  Account getAccount(String id) {
    final account = _accounts.firstWhere((e) => e.id == id);

    return account;
  }

  int getAccountIndex(String id) {
    return _accounts.indexWhere((e) => e.id == id);
  }

  int removeAccount(String id) {
    final index = _accounts.indexWhere((e) => e.id == id);
    if (index != -1) {
      _accounts.removeAt(index);
    }

    return index;
  }

  Future<int> getAssetCount(TransactableAccount account) async {
    var count = _assetCounts[account.id];
    if (count == null) {
      final assets =
          await _assetService.getAssets(account.coin, account.address);
      count = assets.length;
      _assetCounts[account.id] = count;
    }

    return count;
  }

  @override
  FutureOr onDispose() {
    _subscriptions.dispose();
    _count.close();
    _insert.close();
    _updated.close();
    _loading.close();
  }

  Future<void> _onAdded(Account account) async {
    _accounts.add(account);
    _insert.tryAdd(_accounts.length - 1);
  }

  void _onUpdated(TransactableAccount account) {
    final index = _accounts.indexWhere((e) => e.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
      _assetCounts.remove(account.id);
      _updated.add(account);
    }
  }

  void _onSelected(TransactableAccount? account) {
    if (account != null) {
      _updated.add(account);
    }
  }
}
