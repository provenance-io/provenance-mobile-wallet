import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/account_service/wallet_storage_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:rxdart/rxdart.dart';

typedef WalletConnectionProvider = WalletConnection Function(
  WalletConnectAddress address,
);

class AccountServiceEvents {
  final _subscriptions = CompositeSubscription();

  final _added = PublishSubject<AccountDetails>();
  final _removed = PublishSubject<List<AccountDetails>>();
  final _updated = PublishSubject<AccountDetails>();
  final _selected = BehaviorSubject<AccountDetails?>.seeded(null);

  Stream<AccountDetails> get added => _added;
  Stream<List<AccountDetails>> get removed => _removed;
  Stream<AccountDetails> get updated => _updated;
  ValueStream<AccountDetails?> get selected => _selected;

  void clear() {
    _subscriptions.clear();
  }

  void dispose() {
    _subscriptions.dispose();

    _added.close();
    _removed.close();
    _updated.close();
    _selected.close();
  }

  void listen(AccountServiceEvents other) {
    other.added.listen(_added.add).addTo(_subscriptions);
    other.removed.listen(_removed.add).addTo(_subscriptions);
    other.updated.listen(_updated.add).addTo(_subscriptions);
    other.selected.listen(_selected.add).addTo(_subscriptions);
  }
}

class AccountService implements Disposable {
  AccountService({
    required AccountStorageService storage,
  }) : _storage = storage;

  final AccountStorageService _storage;

  final events = AccountServiceEvents();

  Future<void> init() async {
    final selected = await getSelectedAccount();
    if (selected == null) {
      selectAccount();
    } else {
      events._selected.add(selected);
    }
  }

  @override
  FutureOr onDispose() {
    events.dispose();
  }

  Future<AccountDetails?> selectAccount({String? id}) async {
    final details = await _storage.selectAccount(id: id);

    events._selected.add(details);

    return details;
  }

  Future<AccountDetails?> getSelectedAccount() => _storage.getSelectedAccount();

  Future<List<AccountDetails>> getAccounts() => _storage.getAccounts();

  Future<AccountDetails?> renameAccount({
    required String id,
    required String name,
  }) async {
    final details = await _storage.renameAccount(
      id: id,
      name: name,
    );

    if (details != null) {
      events._updated.add(details);
      if (events.selected.value?.id == details.id) {
        selectAccount(id: details.id);
      }
    }

    return details;
  }

  Future<AccountDetails?> setAccountCoin({
    required String id,
    required Coin coin,
  }) async {
    final details = await _storage.setAccountCoin(
      id: id,
      coin: coin,
    );

    if (details != null) {
      events._updated.add(details);
      if (events.selected.value?.id == details.id) {
        selectAccount(id: details.id);
      }
    }

    return details;
  }

  Future<AccountDetails?> addAccount({
    required List<String> phrase,
    required String name,
    required Coin coin,
  }) async {
    final seed = Mnemonic.createSeed(phrase);
    final privateKeys = [
      PrivateKey.fromSeed(seed, Coin.mainNet),
      PrivateKey.fromSeed(seed, Coin.testNet),
    ];

    final details = await _storage.addAccount(
      name: name,
      privateKeys: privateKeys,
      selectedCoin: coin,
    );

    if (details != null) {
      events._added.add(details);
      if (events.selected.value == null) {
        selectAccount(id: details.id);
      }
    }

    return details;
  }

  Future<AccountDetails?> removeAccount({required String id}) async {
    var details = await _storage.getAccount(id);
    if (details != null) {
      final success = await _storage.removeAccount(id);
      if (success) {
        events._removed.add([details]);
        if (events.selected.value?.id == id) {
          selectAccount();
        }
      } else {
        details = null;
      }
    }

    return details;
  }

  Future<List<AccountDetails>> resetAccounts() async {
    final accounts = await _storage.getAccounts();

    final success = await _storage.removeAllAccounts();
    if (success) {
      events._removed.add(accounts);
      events._selected.add(null);
    } else {
      accounts.clear();
    }

    return accounts;
  }

  Future<PrivateKey?> loadKey(String accountId) async {
    final coin = events.selected.value?.coin;
    PrivateKey? privateKey;
    if (coin != null) {
      privateKey = await _storage.loadKey(accountId, coin);
    }

    return privateKey;
  }

  Future<bool> isValidWalletConnectData(String qrData) =>
      Future.value(WalletConnectAddress.create(qrData) != null);
}
