import 'dart:async';

import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';

typedef WalletConnectionProvider = WalletConnection Function(
  WalletConnectAddress address,
);

class AccountServiceEvents {
  final _subscriptions = CompositeSubscription();

  final _added = PublishSubject<Account>();
  final _removed = PublishSubject<List<Account>>();
  final _updated = PublishSubject<Account>();
  final _selected = BehaviorSubject<Account?>.seeded(null);

  Stream<Account> get added => _added;
  Stream<List<Account>> get removed => _removed;
  Stream<Account> get updated => _updated;
  ValueStream<Account?> get selected => _selected;

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
  }) : _storage = storage {
    _init();
  }

  final AccountStorageService _storage;

  final events = AccountServiceEvents();

  @override
  FutureOr onDispose() {
    events.dispose();
  }

  Future<Account?> getAccount(
    String id,
  ) async {
    return _storage.getAccount(id);
  }

  Future<Account?> selectFirstAccount() async {
    final id = (await _storage.getAccounts())
        .firstWhereOrNull((e) => e.publicKey != null)
        ?.id;

    return await selectAccount(id: id);
  }

  Future<Account?> selectAccount({String? id}) async {
    final details = await _storage.selectAccount(id: id);

    events._selected.add(details);

    return details;
  }

  Future<TransactableAccount?> getSelectedAccount() =>
      _storage.getSelectedAccount();

  Future<List<Account>> getAccounts() async {
    final accounts = await _storage.getAccounts();

    return accounts;
  }

  Future<List<BasicAccount>> getBasicAccounts() => _storage.getBasicAccounts();

  Future<List<TransactableAccount>> getTransactableAccounts() async {
    final accounts = await _storage.getAccounts();

    return accounts.whereType<TransactableAccount>().toList();
  }

  Future<Account?> renameAccount({
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

  Future<Account?> setAccountCoin({
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

  Future<Account?> addAccount({
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
      if (events.selected.valueOrNull == null) {
        selectAccount(id: details.id);
      }
    }

    return details;
  }

  Future<MultiAccount?> addMultiAccount({
    required String name,
    required Coin coin,
    required String linkedAccountId,
    required String remoteId,
    required int cosignerCount,
    required int signaturesRequired,
    required List<String> inviteIds,
  }) async {
    final details = await _storage.addMultiAccount(
      name: name,
      selectedCoin: coin,
      linkedAccountId: linkedAccountId,
      remoteId: remoteId,
      cosignerCount: cosignerCount,
      signaturesRequired: signaturesRequired,
      inviteIds: inviteIds,
    );

    if (details != null) {
      events._added.add(details);
      if (events.selected.value == null) {
        selectAccount(id: details.id);
      }

      events._updated.add(details.linkedAccount);
    }

    return details;
  }

  Future<MultiTransactableAccount?> activateMultiAccount({
    required String id,
    required List<PublicKey> publicKeys,
  }) async {
    final account = await _storage.setMultiAccountPublicKeys(
      id: id,
      publicKeys: publicKeys,
    );

    if (account != null) {
      events._updated.add(account);
    }

    return account is MultiTransactableAccount ? account : null;
  }

  Future<Account?> removeAccount({required String id}) async {
    var account = await _storage.getAccount(id);
    if (account != null) {
      final success = await _storage.removeAccount(id);
      if (success) {
        events._removed.add([account]);
        if (events.selected.value?.id == id) {
          final accounts = await getAccounts();
          final first = accounts.firstOrNull;
          if (first != null) {
            await selectAccount(id: first.id);
          }
        }

        if (account is MultiAccount) {
          final linkedAccount =
              await _storage.getAccount(account.linkedAccount.id);
          if (linkedAccount != null) {
            events._updated.add(linkedAccount);
          }
        }
      } else {
        account = null;
      }
    }

    return account;
  }

  Future<List<Account>> resetAccounts() async {
    var accounts = <Account>[];

    try {
      accounts = await _storage.getAccounts();
    } catch (e) {
      logError(
        'Failed to get accounts',
        error: e,
      );
    }

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
    final coin = events.selected.value?.publicKey?.coin;
    PrivateKey? privateKey;
    if (coin != null) {
      privateKey = await _storage.loadKey(accountId, coin);
    }

    return privateKey;
  }

  Future<bool> isValidWalletConnectData(String qrData) =>
      Future.value(WalletConnectAddress.create(qrData) != null);

  Future<void> _init() async {
    final account = await getSelectedAccount();
    if (account != null) {
      events._selected.add(account);
    }
  }
}
