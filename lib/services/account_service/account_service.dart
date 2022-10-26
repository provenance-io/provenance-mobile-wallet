import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart';
import 'package:provenance_wallet/common/classes/pw_error.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

typedef WalletConnectionProvider = WalletConnection Function(
  WalletConnectAddress address,
);

enum AccountServiceError implements PwError {
  accountNotActivated,
  accountNotCreated,
  accountNotRenamed,
  privateKeyNotFound;

  @override
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case AccountServiceError.accountNotActivated:
        return Strings.of(context).errorAccountNotActivated;
      case AccountServiceError.accountNotCreated:
        return Strings.of(context).errorAccountNotCreated;
      case AccountServiceError.accountNotRenamed:
        return Strings.of(context).errorAccountNotRenamed;
      case AccountServiceError.privateKeyNotFound:
        return Strings.of(context).errorPrivateKeyNotFound;
    }
  }
}

class AccountServiceEvents {
  final _subscriptions = CompositeSubscription();

  final _added = PublishSubject<Account>();
  final _removed = PublishSubject<List<Account>>();
  final _updated = PublishSubject<Account>();
  final _selected = BehaviorSubject<TransactableAccount?>.seeded(null);

  Stream<Account> get added => _added;
  Stream<List<Account>> get removed => _removed;
  Stream<Account> get updated => _updated;
  ValueStream<TransactableAccount?> get selected => _selected;

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
        .firstWhereOrNull((e) => e is TransactableAccount)
        ?.id;

    return await selectAccount(id: id);
  }

  Future<TransactableAccount?> selectAccount({String? id}) async {
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

  Future<Account> renameAccount({
    required String id,
    required String name,
  }) async {
    final details = await _storage.renameAccount(
      id: id,
      name: name,
    );

    if (details == null) {
      throw AccountServiceError.accountNotCreated;
    }

    events._updated.add(details);
    if (events.selected.value?.id == details.id) {
      selectAccount(id: details.id);
    }

    return details;
  }

  Future<BasicAccount> addAccount({
    required List<String> phrase,
    required String name,
    required Coin coin,
  }) async {
    final seed = Mnemonic.createSeed(phrase);

    final privateKey = PrivateKey.fromSeed(seed, coin);

    final details = await _storage.addAccount(
      name: name,
      privateKey: privateKey,
    );

    if (details == null) {
      throw AccountServiceError.accountNotCreated;
    }

    events._added.add(details);
    if (events.selected.valueOrNull == null) {
      selectAccount(id: details.id);
    }

    return details;
  }

  Future<MultiAccount> addMultiAccount({
    required String name,
    required Coin coin,
    required String linkedAccountId,
    required String remoteId,
    required int cosignerCount,
    required int signaturesRequired,
    required List<String> inviteIds,
    List<MultiSigSigner>? signers,
  }) async {
    final details = await _storage.addMultiAccount(
      name: name,
      selectedCoin: coin,
      linkedAccountId: linkedAccountId,
      remoteId: remoteId,
      cosignerCount: cosignerCount,
      signaturesRequired: signaturesRequired,
      inviteIds: inviteIds,
      signers: signers,
    );

    if (details == null) {
      throw AccountServiceError.accountNotCreated;
    }

    events._added.add(details);
    if (events.selected.value == null) {
      selectAccount(id: details.id);
    }

    events._updated.add(details.linkedAccount);

    return details;
  }

  Future<MultiTransactableAccount> activateMultiAccount({
    required String id,
    required List<MultiSigSigner> signers,
  }) async {
    final account = await _storage.setMultiAccountSigners(
      id: id,
      signers: signers,
    );

    if (account is! MultiTransactableAccount) {
      throw AccountServiceError.accountNotActivated;
    }

    events._updated.add(account);

    return account;
  }

  Future<Account?> removeAccount({required String id}) async {
    var account = await _storage.getAccount(id);
    if (account != null) {
      final success = await _storage.removeAccount(id);
      if (success) {
        events._removed.add([account]);
        if (events.selected.value?.id == id) {
          await selectFirstAccount();
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
      events._removed.tryAdd(accounts);
      events._selected.tryAdd(null);
    } else {
      accounts.clear();
    }

    return accounts;
  }

  Future<PrivateKey> loadKey(String accountId) async {
    final coin = events.selected.value?.coin;
    PrivateKey? privateKey;
    if (coin != null) {
      privateKey = await _storage.loadKey(accountId, coin);
    }

    if (privateKey == null) {
      throw AccountServiceError.privateKeyNotFound;
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
