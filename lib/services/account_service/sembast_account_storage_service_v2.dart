import 'package:collection/collection.dart';
import 'package:convert/convert.dart' as convert;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart';
import 'package:provenance_wallet/extension/list_extension.dart';
import 'package:provenance_wallet/network.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';
import 'package:provenance_wallet/services/account_service/sembast_schema_v1.dart'
    as v1;
import 'package:provenance_wallet/services/account_service/sembast_schema_v2.dart'
    as v2;
import 'package:provenance_wallet/services/account_service/version_data.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/public_key_util.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/utils/sembast_import_export.dart' as ie;

class SembastAccountStorageServiceV2 implements AccountStorageServiceCore {
  SembastAccountStorageServiceV2({
    required DatabaseFactory factory,
    required String dbPath,
    Map<dynamic, dynamic>? import,
  }) : _factory = factory {
    Future<Database> initDb(
        DatabaseFactory factory, Map<dynamic, dynamic>? import) async {
      if (import != null) {
        await ie.importDatabase(import, factory, dbPath);
      }

      Future<void> onVersionChanged(
          Database db, int oldVersion, int newVersion) async {
        var current = oldVersion;

        // Old version is zero when db is created
        while (current > 0 && current < newVersion) {
          final last = current;
          current++;
          await _update[current]!(db);

          _versionChanged.add(
            VersionData(
              oldVersion: last,
              newVersion: current,
            ),
          );
        }
      }

      _main = StoreRef<String, String>.main();
      _basicAccounts = stringMapStoreFactory.store('accounts');
      _multiAccounts = stringMapStoreFactory.store('multi_accounts');

      final db = await factory.openDatabase(
        dbPath,
        version: version,
        onVersionChanged: onVersionChanged,
      );

      return db;
    }

    _db = initDb(factory, import);
  }

  static const version = 2;
  static const _keySelectedAccountId = 'selectedAccountId';

  // Schema updates go here.
  // Export and commit a sample db before making updates and
  // import the db in unit tests to verify the update process.
  static const _update = <int, Future<void> Function(Database db)>{
    2: _updateV1ToV2,
  };

  final _versionChanged = PublishSubject<VersionData>();
  Stream<VersionData> get versionChanged => _versionChanged;

  final DatabaseFactory _factory;
  late final StoreRef<String, Map<String, Object?>> _basicAccounts;
  late final StoreRef<String, Map<String, Object?>> _multiAccounts;
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
    _versionChanged.close();
  }

  @override
  Future<int> getVersion() async {
    final db = await _db;

    return db.version;
  }

  @override
  Future<BasicAccount?> addBasicAccount({
    required String name,
    required Network network,
    required String publicKeyHex,
  }) async {
    final db = await _db;
    final model = v2.SembastAccountModel(
      name: name,
      publicKey: v2.SembastPublicKeyModel(
        hex: publicKeyHex,
        chainId: network.chainId,
      ),
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

    return [
      ...basic,
      ...multi,
    ];
  }

  @override
  Future<TransactableAccount?> getSelectedAccount() async {
    final db = await _db;
    final selectedId = await _main.record(_keySelectedAccountId).get(db);

    TransactableAccount? account;
    if (selectedId != null && selectedId.isNotEmpty) {
      account = await getAccount(id: selectedId) as TransactableAccount;
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
    final selectedAccountId = await _main.record(_keySelectedAccountId).get(db);

    if (account != null) {
      switch (account.kind) {
        case AccountKind.basic:
          final basic = account as BasicAccount;
          if (basic.linkedAccountIds.isNotEmpty) {
            // If linked, cannot delete
            break;
          }

          key = await db.transaction((tx) async {
            if (account.id == selectedAccountId) {
              // Remove selected account
              await _main.record(_keySelectedAccountId).put(tx, '');
            }

            return await _basicAccounts.record(id).delete(tx);
          });

          break;
        case AccountKind.multi:
          final multiAccount = account as MultiAccount;
          key = await db.transaction((tx) async {
            if (account.id == selectedAccountId) {
              // Remove selected account
              await _main.record(_keySelectedAccountId).put(tx, '');
            }

            // Updated linked basic account
            final linkedAccountRef =
                _basicAccounts.record(multiAccount.linkedAccount.id);
            final linkedAccount = await linkedAccountRef.get(tx);

            if (linkedAccount != null) {
              final linkedAccountModel =
                  v2.SembastAccountModel.fromRecord(linkedAccount);
              final linkedAccountIds = linkedAccountModel.linkedAccountIds
                ..remove(multiAccount.id);

              await linkedAccountRef.update(
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
      }
    }

    return key == null ? 0 : 1;
  }

  @override
  Future<int> removeAllAccounts() async {
    final db = await _db;

    var count = 0;

    await db.transaction((tx) async {
      await _main.record(_keySelectedAccountId).put(tx, '');
      final basic = await _basicAccounts.delete(tx);
      final multi = await _multiAccounts.delete(tx);

      count = basic + multi;
    });

    return count;
  }

  @override
  Future<Account?> renameAccount({
    required String id,
    required String name,
  }) async {
    Account? updatedAccount;

    final account = await getAccount(id: id);
    if (account != null) {
      final db = await _db;

      switch (account.kind) {
        case AccountKind.basic:
          var ref = _basicAccounts.record(id);
          var rec = await ref.get(db);

          if (rec != null) {
            final old = v2.SembastAccountModel.fromRecord(rec);
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
            final old = v2.SembastMultiAccountModel.fromRecord(rec);
            final updated =
                await ref.update(db, old.copyWith(name: name).toRecord());
            if (updated != null) {
              updatedAccount = await _toMulti(id, updated);
            }
          }
          break;
      }
    }

    return updatedAccount;
  }

  @override
  Future<Account?> selectNetwork({
    required String id,
    required String publicKeyHex,
    required Network network,
  }) async {
    Account? updatedAccount;

    final account = await getAccount(id: id);
    if (account != null) {
      final db = await _db;

      switch (account.kind) {
        case AccountKind.basic:
          var ref = _basicAccounts.record(id);
          var rec = await ref.get(db);

          if (rec != null) {
            final old = v2.SembastAccountModel.fromRecord(rec);
            final updated = await ref.update(
                db,
                old
                    .copyWith(
                        publicKey: v2.SembastPublicKeyModel(
                          hex: publicKeyHex,
                          chainId: network.chainId,
                        ),
                        selectedChainId: network.chainId)
                    .toRecord());
            if (updated != null) {
              updatedAccount = _toBasic(id, updated);
            }
          }
          break;
        case AccountKind.multi:
          // Not supported
          break;
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
      final candidate = await getAccount(id: id);
      if (candidate is TransactableAccount) {
        account = candidate;
      }
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
  Future<MultiAccount?> addMultiAccount({
    required String name,
    required String selectedChainId,
    required String linkedAccountId,
    required String remoteId,
    required int cosignerCount,
    required int signaturesRequired,
    required List<String> inviteIds,
    String? address,
    List<MultiSigSigner>? signers,
  }) async {
    final db = await _db;
    final model = v2.SembastMultiAccountModel(
      name: name,
      linkedAccountId: linkedAccountId,
      remoteId: remoteId,
      cosignerCount: cosignerCount,
      signaturesRequired: signaturesRequired,
      inviteIds: inviteIds,
      signers: signers
          ?.map((e) => v2.SembastMultiAccountSigner(
                publicKey: e.publicKey?.compressedPublicKeyHex,
                signerOrder: e.signerOrder,
              ))
          .toList(),
    );

    final id = await db.transaction((tx) async {
      // Add multi-account
      final multiAccountId = await _multiAccounts.add(
        tx,
        model.toRecord(),
      );

      // Updated linked basic account
      final linkedAccountRef = _basicAccounts.record(linkedAccountId);
      final linkedAccount = await linkedAccountRef.get(tx);
      if (linkedAccount != null) {
        final linkedAccountModel =
            v2.SembastAccountModel.fromRecord(linkedAccount);
        final linkedAccountIds = linkedAccountModel.linkedAccountIds
          ..add(multiAccountId)
          ..toSet()
          ..toList();

        await linkedAccountRef.update(
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
  Future<MultiAccount?> setMultiAccountSigners({
    required String id,
    required List<MultiSigSigner> signers,
  }) async {
    final db = await _db;
    final ref = _multiAccounts.record(id);
    final rec = await ref.get(db);
    if (rec != null) {
      final model = v2.SembastMultiAccountModel.fromRecord(rec);
      final updatedModel = model.copyWith(
        signers: signers,
      );

      await ref.update(db, updatedModel.toRecord());
    }

    return getMultiAccount(id: id);
  }

  @override
  Future<MultiAccount?> getMultiAccount({
    required String id,
  }) async {
    final db = await _db;
    MultiAccount? details;

    final rec = await _multiAccounts.record(id).get(db);
    if (rec != null) {
      details = await _toMulti(id, rec);
    }

    return details;
  }

  @override
  Future<List<MultiAccount>> getMultiAccounts() async {
    final db = await _db;
    final recs = await _multiAccounts.find(db);

    final results = <MultiAccount>[];
    for (var rec in recs) {
      final multi = await _toMulti(rec.key, rec.value);
      results.add(multi);
    }

    return results;
  }

  BasicAccount _toBasic(String id, Map<String, Object?> value) {
    final model = v2.SembastAccountModel.fromRecord(value);

    var hex = model.publicKey.hex;
    final coin = Coin.forChainId(model.publicKey.chainId);
    final publicKey =
        PublicKey.fromCompressPublicHex(convert.hex.decoder.convert(hex), coin);

    return BasicAccount(
      id: id,
      name: model.name,
      publicKey: publicKey,
      linkedAccountIds: model.linkedAccountIds,
    );
  }

  Future<MultiAccount> _toMulti(String id, Map<String, Object?> value) async {
    final model = v2.SembastMultiAccountModel.fromRecord(value);

    final linkedAccount = await getBasicAccount(id: model.linkedAccountId);

    final signers = model.signers?.toList();
    signers?.sortAscendingBy((e) => e.signerOrder);

    MultiAccount account;

    final active = linkedAccount != null &&
        signers != null &&
        signers.isNotEmpty &&
        signers.every((e) => e.publicKey != null);
    if (active) {
      final coin = linkedAccount.coin;

      final signerKeys = signers
          .map((e) => publicKeyFromCompressedHex(e.publicKey!, coin))
          .toList();
      final publicKey = AminoPubKey(
        threshold: model.signaturesRequired,
        publicKeys: signerKeys,
        coin: coin,
      );

      account = MultiTransactableAccount(
        id: id,
        name: model.name,
        linkedAccount: linkedAccount,
        remoteId: model.remoteId,
        cosignerCount: model.cosignerCount,
        signaturesRequired: model.signaturesRequired,
        inviteIds: model.inviteIds,
        publicKey: publicKey,
      );
    } else {
      account = MultiAccount(
        id: id,
        name: model.name,
        linkedAccount: linkedAccount!,
        remoteId: model.remoteId,
        cosignerCount: model.cosignerCount,
        signaturesRequired: model.signaturesRequired,
        inviteIds: model.inviteIds,
      );
    }

    return account;
  }

  ///
  /// V2 accounts only have a single chain-id. Migrate mainnet and toss
  /// testnet. Testnet accounts will have to be re-imported as a separate
  /// account.
  ///
  static Future<void> _updateV1ToV2(Database db) async {
    final store = stringMapStoreFactory.store('accounts');
    final snapshots = await store.find(db);

    for (final snapshot in snapshots) {
      final accountModelV1 = v1.SembastAccountModel.fromRecord(snapshot.value);
      final publicKeyV1 = accountModelV1.publicKeys
          .firstWhereOrNull((e) => e.chainId == Coin.mainNet.chainId);
      if (publicKeyV1 != null) {
        final publicKeyV2 = v2.SembastPublicKeyModel(
          chainId: publicKeyV1.chainId,
          hex: publicKeyV1.hex,
        );
        final accountModelV2 = v2.SembastAccountModel(
          name: accountModelV1.name,
          publicKey: publicKeyV2,
          linkedAccountIds: accountModelV1.linkedAccountIds,
        );

        await snapshot.ref.put(
          db,
          accountModelV2.toRecord(),
        );
      } else {
        snapshot.ref.delete(db);
      }
    }
  }
}
