import 'package:path/path.dart' as p;
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';
import 'package:provenance_wallet/services/account_service/sembast_schema_v1.dart'
    as v1;
import 'package:provenance_wallet/services/account_service/wallet_storage_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
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

      _accounts = stringMapStoreFactory.store('accounts');

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
  late final StoreRef<String, Map<String, Object?>> _accounts;
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
  Future<AccountDetails?> addAccount({
    required String name,
    required List<PublicKeyData> publicKeys,
    required String selectedChainId,
    AccountKind kind = AccountKind.single,
  }) async {
    final db = await _db;
    final model = v1.SembastAccountModel(
      name: name,
      publicKeys: publicKeys
          .map((e) => v1.SembastPublicKeyModel(
                address: e.address,
                hex: e.hex,
                chainId: e.chainId,
              ))
          .toList(),
      selectedChainId: selectedChainId,
      kind: _toKindV1(kind),
    );
    final id = await _accounts.add(
      db,
      model.toRecord(),
    );

    return getAccount(id: id);
  }

  @override
  Future<AccountDetails?> getAccount({
    required String id,
  }) async {
    final db = await _db;
    AccountDetails? details;

    final rec = await _accounts.record(id).get(db);
    if (rec != null) {
      details = _toDetails(id, rec);
    }

    return details;
  }

  @override
  Future<List<AccountDetails>> getAccounts() async {
    final db = await _db;
    final recs = await _accounts.find(db);

    return recs.map((e) {
      return _toDetails(e.key, e.value);
    }).toList();
  }

  @override
  Future<AccountDetails?> getSelectedAccount() async {
    final db = await _db;
    final selectedId = await _main.record(_keySelectedAccountId).get(db);

    AccountDetails? details;
    if (selectedId != null && selectedId.isNotEmpty) {
      details = await getAccount(id: selectedId);
    }

    return details;
  }

  @override
  Future<int> removeAccount({
    required String id,
  }) async {
    final db = await _db;
    final key = await _accounts.record(id).delete(db);

    return key == null ? 0 : 1;
  }

  @override
  Future<int> removeAllAccounts() async {
    final db = await _db;
    final count = await _accounts.delete(db);

    return count;
  }

  @override
  Future<AccountDetails?> renameAccount({
    required String id,
    required String name,
  }) async {
    final db = await _db;
    final ref = _accounts.record(id);
    final rec = await ref.get(db);

    Map<String, Object?>? updated;

    if (rec != null) {
      final old = v1.SembastAccountModel.fromRecord(rec);
      updated = await ref.update(db, old.copyWith(name: name).toRecord());
    }

    return updated == null ? null : _toDetails(id, updated);
  }

  @override
  Future<AccountDetails?> selectAccount({
    String? id,
  }) async {
    final db = await _db;

    AccountDetails? details;

    if (id != null) {
      final accountValue = await _accounts.record(id).get(db);
      if (accountValue != null) {
        details = _toDetails(id, accountValue);
      }
    }

    var success = false;
    if (id == null || details != null) {
      final updatedId =
          await _main.record(_keySelectedAccountId).put(db, id ?? '');
      success = updatedId == id;
    }

    return success ? details : null;
  }

  @override
  Future<AccountDetails?> setChainId({
    required String id,
    required String chainId,
  }) async {
    final db = await _db;

    AccountDetails? details;

    final accountRec = _accounts.record(id);
    final accountValue = await accountRec.get(db);
    if (accountValue != null) {
      final accountModel = v1.SembastAccountModel.fromRecord(accountValue);
      final updatedAccountModel = accountModel.copyWith(
        selectedChainId: chainId,
      );
      final updatedAccountValue = await accountRec.update(
        db,
        updatedAccountModel.toRecord(),
      );
      if (updatedAccountValue != null) {
        details = _toDetails(id, updatedAccountValue);
      }
    }

    return details;
  }

  AccountDetails _toDetails(String id, Map<String, Object?> value) {
    final model = v1.SembastAccountModel.fromRecord(value);
    final chainId = model.selectedChainId;

    var address = '';
    var hex = '';

    if (model.publicKeys.isNotEmpty) {
      final selectedKey = model.publicKeys
          .firstWhere((e) => e.chainId == model.selectedChainId);
      address = selectedKey.address;
      hex = selectedKey.hex;
    }

    return AccountDetails(
      id: id,
      name: model.name,
      address: address,
      publicKey: hex,
      coin: ChainId.toCoin(chainId),
      kind: _fromKindV1(model.kind),
    );
  }

  v1.SembastAccountKind _toKindV1(AccountKind kind) {
    return v1.SembastAccountKind.values.byName(kind.name);
  }

  AccountKind _fromKindV1(v1.SembastAccountKind kind) {
    return AccountKind.values.byName(kind.name);
  }
}
