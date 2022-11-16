import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart';
import 'package:provenance_wallet/common/classes/pw_error.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/network.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

import 'account_storage_service_core.dart';

typedef WalletConnectionProvider = WalletConnection Function(
  WalletConnectAddress address,
);

enum AccountServiceError implements PwError {
  accountNotActivated,
  accountNotCreated,
  accountNotFound,
  accountNotRenamed,
  networkNotChanged,
  privateKeyNotFound;

  @override
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case AccountServiceError.accountNotActivated:
        return Strings.of(context).errorAccountNotActivated;
      case AccountServiceError.accountNotCreated:
        return Strings.of(context).errorAccountNotCreated;
      case AccountServiceError.accountNotFound:
        return Strings.of(context).errorAccountNotFound;
      case AccountServiceError.accountNotRenamed:
        return Strings.of(context).errorAccountNotRenamed;
      case AccountServiceError.privateKeyNotFound:
        return Strings.of(context).errorPrivateKeyNotFound;
      case AccountServiceError.networkNotChanged:
        return Strings.of(context).errorNetworkNotChanged;
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
    required AccountStorageServiceCore storage,
    required KeyValueService keyValueService,
    required CipherService cipherService,
  })  : _storage = storage,
        _keyValueService = keyValueService,
        _cipherService = cipherService {
    _initFuture = _init();
  }

  static const version = 1;

  final AccountStorageServiceCore _storage;
  final KeyValueService _keyValueService;
  final CipherService _cipherService;

  final events = AccountServiceEvents();

  late final Future<void> _initFuture;

  @override
  FutureOr onDispose() {
    events.dispose();
  }

  Future<Account?> getAccount(
    String id,
  ) async {
    await _initFuture;

    return _storage.getAccount(id: id);
  }

  Future<Account?> selectFirstAccount() async {
    await _initFuture;

    final id = (await _storage.getAccounts())
        .firstWhereOrNull((e) => e is TransactableAccount)
        ?.id;

    return await selectAccount(id: id);
  }

  Future<TransactableAccount?> selectAccount({String? id}) async {
    await _initFuture;

    final details = await _storage.selectAccount(id: id);

    events._selected.add(details);

    return details;
  }

  Future<TransactableAccount?> getSelectedAccount() async {
    await _initFuture;

    return _storage.getSelectedAccount();
  }

  Future<List<Account>> getAccounts() async {
    await _initFuture;

    final accounts = await _storage.getAccounts();

    return accounts;
  }

  Future<List<BasicAccount>> getBasicAccounts() async {
    await _initFuture;

    return _storage.getBasicAccounts();
  }

  Future<List<TransactableAccount>> getTransactableAccounts() async {
    await _initFuture;

    final accounts = await _storage.getAccounts();

    return accounts.whereType<TransactableAccount>().toList();
  }

  Future<Account> renameAccount({
    required String id,
    required String name,
  }) async {
    await _initFuture;

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

  Future<Account> selectNetwork({
    required String accountId,
    required Network network,
  }) async {
    await _initFuture;

    final serialized = await _cipherService.decryptKey(id: accountId);
    if (serialized == null) {
      throw AccountServiceError.privateKeyNotFound;
    }

    final coin = network.defaultCoin;
    final rootKey = PrivateKey.fromBip32(serialized);
    final nodes = DerivationNode.fromPathString(coin.defaultKeyPath);
    final defaultKey = rootKey.deriveKeyFromPath(nodes);

    // Do this so that the coin and public key are correct.
    // Side effect is that the new key is non-HD.
    final privateKey = PrivateKey.fromPrivateKey(defaultKey.rawHex, coin);

    final publicKeyHex = privateKey.publicKey.compressedPublicKeyHex;

    final account = await _storage.selectNetwork(
      id: accountId,
      network: network,
      publicKeyHex: publicKeyHex,
    );

    if (account == null) {
      throw AccountServiceError.networkNotChanged;
    }

    events._updated.add(account);
    if (events.selected.value?.id == account.id) {
      selectAccount(id: account.id);
    }

    return account;
  }

  Future<BasicAccount> addAccount({
    required List<String> phrase,
    required String name,
    required Network network,
  }) async {
    await _initFuture;

    final seed = Mnemonic.createSeed(phrase);

    final coin = network.defaultCoin;

    final rootKey = PrivateKey.fromSeed(seed, coin);

    final nodes = DerivationNode.fromPathString(coin.defaultKeyPath);
    final derivedKey = rootKey.deriveKeyFromPath(nodes);
    final publicKeyHex = derivedKey.publicKey.compressedPublicKeyHex;

    final details = await _storage.addBasicAccount(
      name: name,
      publicKeyHex: publicKeyHex,
      network: network,
    );

    if (details == null) {
      throw AccountServiceError.accountNotCreated;
    }

    final success = await _cipherService.encryptKey(
      id: details.id,
      privateKey: rootKey.serialize(publicKeyOnly: false),
    );

    if (!success) {
      await _storage.removeAccount(id: details.id);

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
    await _initFuture;

    final details = await _storage.addMultiAccount(
      name: name,
      selectedChainId: coin.chainId,
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
    await _initFuture;

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
    await _initFuture;

    var account = await _storage.getAccount(id: id);
    if (account != null) {
      await _cipherService.removeKey(id: id);

      final count = await _storage.removeAccount(id: id);

      final success = count != 0;

      if (success) {
        events._removed.add([account]);
        if (events.selected.value?.id == id) {
          await selectFirstAccount();
        }

        if (account is MultiAccount) {
          final linkedAccount =
              await _storage.getAccount(id: account.linkedAccount.id);
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
    await _initFuture;

    var accounts = <Account>[];

    try {
      accounts = await _storage.getAccounts();
    } catch (e) {
      logError(
        'Failed to get accounts',
        error: e,
      );
    }

    await _cipherService.resetKeys();
    final count = await _storage.removeAllAccounts();

    final success = count != 0;
    if (success) {
      events._removed.tryAdd(accounts);
      events._selected.tryAdd(null);
    } else {
      accounts.clear();
    }

    return accounts;
  }

  Future<PrivateKey> loadKey(String accountId, Coin coin) async {
    await _initFuture;

    final account = await _storage.getBasicAccount(id: accountId);
    if (account == null) {
      throw AccountServiceError.accountNotFound;
    }

    final serialziedKey = await _cipherService.decryptKey(id: accountId);
    if (serialziedKey == null) {
      throw AccountServiceError.privateKeyNotFound;
    }

    final nodes = DerivationNode.fromPathString(coin.defaultKeyPath);
    final derivedKey =
        PrivateKey.fromBip32(serialziedKey).deriveKeyFromPath(nodes);

    // Do this so that the coin and public key are correct.
    // Side effect is that the new key is non-HD.
    final privateKey = PrivateKey.fromPrivateKey(derivedKey.rawHex, coin);

    return privateKey;
  }

  Future<bool> isValidWalletConnectData(String qrData) async {
    await _initFuture;

    return WalletConnectAddress.create(qrData) != null;
  }

  Future<void> _init() async {
    final current =
        await _keyValueService.getString(PrefKey.accountServiceVersion) ?? '0';
    var currentInt = int.parse(current);

    while (currentInt < version) {
      await _upgrades[currentInt]!.call();

      currentInt++;

      await _keyValueService.setString(
        PrefKey.accountServiceVersion,
        currentInt.toString(),
      );
    }

    final account = await _storage.getSelectedAccount();
    if (account != null) {
      events._selected.add(account);
    }
  }

  late final _upgrades = {
    0: _upgradeV0toV1,
  };

  Future<void> _upgradeV0toV1() async {
    final accounts = await _storage.getBasicAccounts();
    for (final account in accounts) {
      for (final coin in [Coin.testNet, Coin.mainNet]) {
        final oldId = '${account.id}-${coin.chainId}';
        final privateKey = await _cipherService.decryptKey(id: oldId);
        if (privateKey != null) {
          await _cipherService.encryptKey(
            id: account.id,
            privateKey: privateKey,
          );
          break;
        }
      }
    }
  }
}
