import 'package:convert/convert.dart' as convert;
import 'package:path/path.dart' as p;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';
import 'package:provenance_wallet/services/account_service/sembast_schema_v1.dart'
    as v1;
import 'package:provenance_wallet/services/models/account.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/utils/sembast_import_export.dart' as ie;

class SembastAccountStorageService implements AccountStorageServiceCore {
  SembastAccountStorageService({
    required DatabaseFactory factory,
    required String directory,
    Map<dynamic, dynamic>? import,
  }) : _factory = factory {
    final path = p.join(directory, _fileName);
    if (import != null) {
      ie.importDatabase(import, factory, path);
    }

    _main = StoreRef<String, String>.main();

    Future<Database> initDb(DatabaseFactory factory) async {
      Future<void> onVersionChanged(
          Database db, int oldVersion, int newVersion) async {
        var current = oldVersion;
        // Old version is zero when db is created
        while (current > 0 && current < newVersion) {
          current++;
          await _update[current]!(db);
        }
      }

      _basicAccounts = stringMapStoreFactory.store('accounts');
      _multiAccounts = stringMapStoreFactory.store('multi_accounts');
      _pendingMultiAccounts =
          stringMapStoreFactory.store('pending_multi_accounts');

      final db = await factory.openDatabase(
        path,
        version: version,
        onVersionChanged: onVersionChanged,
      );

      return db;
    }

    _db = initDb(factory);
  }

  static const version = 1;
  static const _fileName = 'account.db';
  static const _keySelectedAccountId = 'selectedAccountId';

  // Schema updates go here.
  // Export and commit a sample db before making updates and
  // import the db in unit tests to verify the update process.
  static const _update = <int, Future<void> Function(Database db)>{
    // 2: _updateV1ToV2,
  };

  final DatabaseFactory _factory;
  late final StoreRef<String, Map<String, Object?>> _basicAccounts;
  late final StoreRef<String, Map<String, Object?>> _multiAccounts;
  late final StoreRef<String, Map<String, Object?>> _pendingMultiAccounts;
  late final StoreRef<String, String?> _main;
  late final Future<Database> _db;

  Future<Map<String, Object?>> exportDatabase() async {
    final db = await _db;

    return ie.exportDatabase(db);
  }

  Future<void> deleteDatabase() async {
    final db = await _db;
    final path = db.path;
    await db.close();

    await _factory.deleteDatabase(path);
  }

  Future<void> close() async {
    final db = await _db;
    await db.close();
  }

  @override
  Future<int> getVersion() async {
    final db = await _db;

    return db.version;
  }

  @override
  Future<BasicAccount?> addBasicAccount({
    required String name,
    required List<PublicKeyData> publicKeys,
    required String selectedChainId,
  }) async {
    final db = await _db;
    final model = v1.SembastAccountModel(
      name: name,
      publicKeys: publicKeys
          .map((e) => v1.SembastPublicKeyModel(
                hex: e.hex,
                chainId: e.chainId,
              ))
          .toList(),
      selectedChainId: selectedChainId,
      linkedAccountIds: [],
    );
    final id = await _basicAccounts.add(
      db,
      model.toRecord(),
    );

    return getBasicAccount(id: id);
  }

  @override
  Future<Account?> getAccount({
    required String id,
  }) async {
    Account? account = await getBasicAccount(id: id);
    account ??= await getMultiAccount(id: id);
    account ??= await getPendingMultiAccount(id: id);

    return account;
  }

  @override
  Future<BasicAccount?> getBasicAccount({
    required String id,
  }) async {
    final db = await _db;
    BasicAccount? details;

    final rec = await _basicAccounts.record(id).get(db);
    if (rec != null) {
      details = _toBasic(id, rec);
    }

    return details;
  }

  @override
  Future<List<BasicAccount>> getBasicAccounts() async {
    final db = await _db;
    final recs = await _basicAccounts.find(db);

    return recs.map((e) {
      return _toBasic(e.key, e.value);
    }).toList();
  }

  @override
  Future<List<Account>> getAccounts() async {
    final basic = await getBasicAccounts();
    final multi = await getMultiAccounts();
    final pending = await getPendingMultiAccounts();

    return [
      ...basic,
      ...multi,
      ...pending,
    ];
  }

  @override
  Future<TransactableAccount?> getSelectedAccount() async {
    final db = await _db;
    final selectedId = await _main.record(_keySelectedAccountId).get(db);

    TransactableAccount? account;
    if (selectedId != null && selectedId.isNotEmpty) {
      account = await getAccount(id: selectedId) as TransactableAccount?;
    }

    return account;
  }

  @override
  Future<int> removeAccount({
    required String id,
  }) async {
    final db = await _db;

    String? key;

    final account = await getAccount(id: id);

    if (account != null) {
      switch (account.kind) {
        case AccountKind.basic:
          final basic = account as BasicAccount;
          if (basic.linkedAccountIds.isNotEmpty) {
            // If linked, cannot delete
            break;
          }

          key = await _basicAccounts.record(id).delete(db);
          break;
        case AccountKind.multi:
          final multiAccount = account as MultiAccount;
          key = await db.transaction((tx) async {
            // Updated linked basic account
            final linkedAccount = await _basicAccounts
                .record(multiAccount.linkedAccountId)
                .get(tx);

            if (linkedAccount != null) {
              final linkedAccountModel =
                  v1.SembastAccountModel.fromRecord(linkedAccount);
              final linkedAccountIds = linkedAccountModel.linkedAccountIds
                ..remove(multiAccount.id);

              await _basicAccounts.update(
                tx,
                linkedAccountModel
                    .copyWith(
                      linkedAccountIds: linkedAccountIds,
                    )
                    .toRecord(),
              );
            }

            // Delete record
            return await _multiAccounts.record(id).delete(tx);
          });
          break;
        case AccountKind.pendingMulti:
          key = await _pendingMultiAccounts.record(id).delete(db);
          break;
      }
    }

    return key == null ? 0 : 1;
  }

  @override
  Future<int> removeAllAccounts() async {
    final db = await _db;

    var count = 0;

    await db.transaction((tx) async {
      final basic = await _basicAccounts.delete(tx);
      final multi = await _multiAccounts.delete(tx);
      final pending = await _pendingMultiAccounts.delete(tx);

      count = basic + multi + pending;
    });

    return count;
  }

  @override
  Future<TransactableAccount?> renameAccount({
    required String id,
    required String name,
  }) async {
    TransactableAccount? updatedAccount;

    final account = await getAccount(id: id);
    if (account != null) {
      final db = await _db;

      switch (account.kind) {
        case AccountKind.basic:
          var ref = _basicAccounts.record(id);
          var rec = await ref.get(db);

          if (rec != null) {
            final old = v1.SembastAccountModel.fromRecord(rec);
            final updated =
                await ref.update(db, old.copyWith(name: name).toRecord());
            if (updated != null) {
              updatedAccount = _toBasic(id, updated);
            }
          }
          break;
        case AccountKind.multi:
          var ref = _multiAccounts.record(id);
          var rec = await ref.get(db);

          if (rec != null) {
            final old = v1.SembastMultiAccountModel.fromRecord(rec);
            final updated =
                await ref.update(db, old.copyWith(name: name).toRecord());
            if (updated != null) {
              updatedAccount = _toMulti(id, updated);
            }
          }
          break;
        case AccountKind.pendingMulti:
          throw 'Rename not supported for ${account.kind}';
      }
    }

    return updatedAccount;
  }

  @override
  Future<TransactableAccount?> selectAccount({
    String? id,
  }) async {
    final db = await _db;

    TransactableAccount? account;

    if (id != null) {
      account = await getAccount(id: id) as TransactableAccount?;
    }

    var success = false;
    if (id == null || account != null) {
      final updatedId =
          await _main.record(_keySelectedAccountId).put(db, id ?? '');
      success = updatedId == id;
    }

    return success ? account : null;
  }

  @override
  Future<TransactableAccount?> setChainId({
    required String id,
    required String chainId,
  }) async {
    TransactableAccount? updatedAccount;

    final account = await getAccount(id: id);
    if (account != null) {
      final db = await _db;

      switch (account.kind) {
        case AccountKind.basic:
          final ref = _basicAccounts.record(id);
          final rec = await ref.get(db);
          if (rec != null) {
            final model = v1.SembastAccountModel.fromRecord(rec);
            final updatedModel = model.copyWith(
              selectedChainId: chainId,
            );
            final updatedRec = await ref.update(
              db,
              updatedModel.toRecord(),
            );
            if (updatedRec != null) {
              updatedAccount = _toBasic(id, updatedRec);
            }
          }
          break;
        case AccountKind.multi:
          final ref = _multiAccounts.record(id);
          final rec = await ref.get(db);
          if (rec != null) {
            final model = v1.SembastMultiAccountModel.fromRecord(rec);
            final updatedModel = model.copyWith(
              selectedChainId: chainId,
            );
            final updatedRec = await ref.update(
              db,
              updatedModel.toRecord(),
            );
            if (updatedRec != null) {
              updatedAccount = _toMulti(id, updatedRec);
            }
          }
          break;
        case AccountKind.pendingMulti:
          throw 'setChainId not supported for ${account.kind}';
      }
    }

    return updatedAccount;
  }

  @override
  Future<MultiAccount?> addMultiAccount({
    required String name,
    required List<PublicKey> publicKeys,
    required String selectedChainId,
    required String linkedAccountId,
  }) async {
    final db = await _db;
    final model = v1.SembastMultiAccountModel(
      name: name,
      publicKeys: publicKeys
          .map((e) => v1.SembastPublicKeyModel(
                hex: e.compressedPublicKeyHex,
                chainId: ChainId.forCoin(e.coin),
              ))
          .toList(),
      selectedChainId: selectedChainId,
      linkedAccountId: linkedAccountId,
    );

    final id = await db.transaction((tx) async {
      // Add multi-account
      final multiAccountId = await _multiAccounts.add(
        tx,
        model.toRecord(),
      );

      // Updated linked basic account
      final linkedAccount =
          await _basicAccounts.record(linkedAccountId).get(tx);
      if (linkedAccount != null) {
        final linkedAccountModel =
            v1.SembastAccountModel.fromRecord(linkedAccount);
        final linkedAccountIds = linkedAccountModel.linkedAccountIds
          ..add(multiAccountId)
          ..toSet()
          ..toList();

        await _basicAccounts.update(
          tx,
          linkedAccountModel
              .copyWith(
                linkedAccountIds: linkedAccountIds,
              )
              .toRecord(),
        );
      }

      return multiAccountId;
    });

    return getMultiAccount(id: id);
  }

  @override
  Future<PendingMultiAccount?> addPendingMultiAccount({
    required String name,
    required String remoteId,
    required String linkedAccountId,
    required int cosignerCount,
    required int signaturesRequired,
    required List<String> inviteLinks,
  }) async {
    final db = await _db;

    final model = v1.SembastPendingMultiAccountModel(
      name: name,
      remoteId: remoteId,
      linkedAccountId: linkedAccountId,
      cosignerCount: cosignerCount,
      signaturesRequired: signaturesRequired,
      inviteLinks: inviteLinks,
    );
    final id = await _pendingMultiAccounts.add(
      db,
      model.toRecord(),
    );

    return getPendingMultiAccount(id: id);
  }

  @override
  Future<MultiAccount?> getMultiAccount({
    required String id,
  }) async {
    final db = await _db;
    MultiAccount? details;

    final rec = await _multiAccounts.record(id).get(db);
    if (rec != null) {
      details = _toMulti(id, rec);
    }

    return details;
  }

  @override
  Future<List<MultiAccount>> getMultiAccounts() async {
    final db = await _db;
    final recs = await _multiAccounts.find(db);

    return recs.map((e) {
      return _toMulti(e.key, e.value);
    }).toList();
  }

  @override
  Future<PendingMultiAccount?> getPendingMultiAccount({
    required String id,
  }) async {
    final db = await _db;
    PendingMultiAccount? account;

    final rec = await _pendingMultiAccounts.record(id).get(db);
    if (rec != null) {
      account = await _toPendingMulti(id, rec);
    }

    return account;
  }

  @override
  Future<List<PendingMultiAccount>> getPendingMultiAccounts() async {
    final db = await _db;
    final recs = await _pendingMultiAccounts.find(db);

    final accounts = <PendingMultiAccount>[];

    for (var rec in recs) {
      final account = await _toPendingMulti(rec.key, rec.value);
      if (account != null) {
        accounts.add(account);
      }
    }

    return accounts;
  }

  BasicAccount _toBasic(String id, Map<String, Object?> value) {
    final model = v1.SembastAccountModel.fromRecord(value);
    final chainId = model.selectedChainId;

    var hex = '';

    if (model.publicKeys.isNotEmpty) {
      final selectedKey = model.publicKeys
          .firstWhere((e) => e.chainId == model.selectedChainId);

      hex = selectedKey.hex;
    }

    final coin = ChainId.toCoin(chainId);
    final publicKey =
        PublicKey.fromCompressPublicHex(convert.hex.decoder.convert(hex), coin);

    return BasicAccount(
      id: id,
      name: model.name,
      publicKey: publicKey,
      linkedAccountIds: model.linkedAccountIds,
    );
  }

  MultiAccount _toMulti(String id, Map<String, Object?> value) {
    final model = v1.SembastMultiAccountModel.fromRecord(value);
    final chainId = model.selectedChainId;

    var hex = '';

    if (model.publicKeys.isNotEmpty) {
      final selectedKey = model.publicKeys
          .firstWhere((e) => e.chainId == model.selectedChainId);

      hex = selectedKey.hex;
    }

    final coin = ChainId.toCoin(chainId);
    final publicKey =
        PublicKey.fromCompressPublicHex(convert.hex.decoder.convert(hex), coin);

    return MultiAccount(
      id: id,
      name: model.name,
      publicKey: publicKey,
      linkedAccountId: model.linkedAccountId,
    );
  }

  Future<PendingMultiAccount?> _toPendingMulti(
      String id, Map<String, Object?> value) async {
    PendingMultiAccount? account;

    final model = v1.SembastPendingMultiAccountModel.fromRecord(value);

    final linkedAccount = await getAccount(id: model.linkedAccountId);
    if (linkedAccount != null) {
      account = PendingMultiAccount(
        id: id,
        name: model.name,
        remoteId: model.remoteId,
        linkedAccountId: model.linkedAccountId,
        linkedAccountName: linkedAccount.name,
        cosignerCount: model.cosignerCount,
        signaturesRequired: model.signaturesRequired,
        inviteLinks: model.inviteLinks,
      );
    }

    return account;
  }
}
