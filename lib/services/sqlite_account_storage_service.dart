import 'dart:io';

import 'package:convert/convert.dart' as convert;
import 'package:path/path.dart' as p;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:sqflite/sqflite.dart';

class SqliteAccountStorageService {
  static const _version = 2;
  static const _name = 'wallet.db';
  static const _sqlCreateTableConfig = '''
    CREATE TABLE "Config" (
      "Id"	INTEGER NOT NULL CHECK("Id" = 1),
      "SelectedId"	INTEGER,
      PRIMARY KEY("Id" AUTOINCREMENT)
    );
  ''';
  static const _sqlInitConfig = '''
    INSERT INTO Config (SelectedId) VALUES (null)
  ''';
  static const _sqlCreateTableAccount = '''
    CREATE TABLE "Wallet" (
      "Id"	INTEGER NOT NULL,
      "Name"  TEXT,
      PRIMARY KEY("Id" AUTOINCREMENT)
    );
  ''';
  static const _sqlCreateTablePublicKey = '''
    CREATE TABLE "PublicKey" (
      "Id"	INTEGER NOT NULL,
      "WalletId"	INTEGER NOT NULL,
      "Address"	TEXT,
      "Hex"	TEXT,
      "ChainId"	TEXT,
      PRIMARY KEY("Id" AUTOINCREMENT)
    );
  ''';
  static const _sqlCreateTableSelectedPublicKey = '''
    CREATE TABLE "SelectedPublicKey" (
	    "WalletId"	INTEGER NOT NULL UNIQUE,
	    "PublicKeyId"	INTEGER NOT NULL,
	    PRIMARY KEY("WalletId")
    );
  ''';
  static const _sqlGetAccounts = '''
    SELECT w.Id, w.Name, pk.Address, pk.Hex, pk.ChainId FROM Wallet w INNER JOIN PublicKey pk ON w.Id = pk.WalletId INNER JOIN SelectedPublicKey spk ON w.Id = spk.WalletId AND pk.Id = spk.PublicKeyId
  ''';
  static const _sqlGetAccount = '''
    SELECT w.Id, w.Name, pk.Address, pk.Hex, pk.ChainId FROM Wallet w INNER JOIN PublicKey pk ON w.Id = pk.WalletId INNER JOIN SelectedPublicKey spk ON w.Id = spk.WalletId AND pk.Id = spk.PublicKeyId WHERE w.Id = ?
  ''';
  static const _sqlGetSelectedAccount = '''
    SELECT w.Id, w.Name, pk.Address, pk.Hex, pk.ChainId FROM Wallet w INNER JOIN SelectedPublicKey spk on w.Id = spk.WalletId INNER JOIN PublicKey pk on pk.Id = spk.PublicKeyId AND pk.Id = spk.PublicKeyId INNER JOIN Config c ON w.Id = c.SelectedId
  ''';
  static const _sqlGetFirstAccount = '''
    SELECT w.Id, w.Name, pk.Address, pk.Hex, pk.ChainId FROM Wallet w INNER JOIN PublicKey pk ON w.Id = pk.WalletId ORDER BY w.Id LIMIT 1
  ''';
  static const _sqlUpdateSelectedAccount = '''
    UPDATE Config SET SelectedId = ? WHERE Id = 1
  ''';
  static const _sqlRenameAccount = '''
    UPDATE Wallet SET Name = ? WHERE Id = ?
  ''';
  static const _sqlDeleteAccount = '''
    DELETE FROM Wallet WHERE Id = ?;
    DELETE FROM PublicKey WHERE WalletId = ?;
    DELETE FROM SelectedPublicKey WHERE WalletId = ?;
  ''';
  static const _sqlDeleteAllAccounts = '''
    DELETE FROM Wallet;
    DELETE FROM PublicKey;
    DELETE FROM SelectedPublicKey;
  ''';

  static Future<Database>? _db;

  static Future<File> getDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, _name);

    return File(path);
  }

  Future<void> close() async {
    final db = await _getDb();
    await db.close();
  }

  Future<List<Account>> getAccounts() async {
    final db = await _getDb();
    final results = await db.rawQuery(_sqlGetAccounts);
    final details = results.map(_mapAccount).toList();

    return details;
  }

  Future<Account?> getAccount({required String id}) async {
    final db = await _getDb();
    final results = await db.rawQuery(_sqlGetAccount, [id]);

    Account? account;
    if (results.isNotEmpty) {
      account = _mapAccount(results[0]);
    }

    return account;
  }

  Future<Account?> getSelectedAccount() async {
    final db = await _getDb();
    final results = await db.rawQuery(_sqlGetSelectedAccount);

    Account? account;
    if (results.isNotEmpty) {
      account = _mapAccount(results[0]);
    }

    return account;
  }

  Future<Account?> selectAccount({String? id}) async {
    final db = await _getDb();

    if (id == null) {
      final results = await db.rawQuery(_sqlGetFirstAccount);
      if (results.isNotEmpty) {
        id = (results[0]['Id'] as int).toString();
      }
    }

    await db.execute(_sqlUpdateSelectedAccount, [id]);

    return getSelectedAccount();
  }

  Future<Account?> renameAccount({
    required String id,
    required String name,
  }) async {
    final db = await _getDb();
    int _ = await db.rawUpdate(_sqlRenameAccount, [name, id]);

    return await getAccount(id: id);
  }

  Future<Account?> setChainId({
    required String id,
    required String chainId,
  }) async {
    final db = await _getDb();
    final selectArgs = [
      id,
      chainId,
    ];
    final selectResults = await db.rawQuery(
      'SELECT pk.Id FROM PublicKey pk WHERE pk.WalletId = ? AND pk.ChainId = ?',
      selectArgs,
    );
    int? publicKeyId;
    if (selectResults.isNotEmpty) {
      publicKeyId = selectResults.first['Id'] as int;
    }

    Account? details;

    if (publicKeyId != null) {
      final updateArgs = [
        publicKeyId,
        id,
      ];

      final rowsChanged = await db.rawUpdate(
        'UPDATE SelectedPublicKey Set PublicKeyId = ? WHERE WalletId = ?',
        updateArgs,
      );

      if (rowsChanged != 0) {
        details = await getAccount(id: id);
      }
    }

    return details;
  }

  Future<Account?> addAccount({
    required String name,
    required List<PublicKeyData> publicKeys,
    required String selectedChainId,
  }) async {
    if (publicKeys.isEmpty || selectedChainId.isEmpty) {
      return null;
    }

    if (!publicKeys.any((e) => e.chainId == selectedChainId)) {
      const message = 'Selected chain id is not in the list of public keys';
      logError(message);
      assert(false, message);

      return null;
    }

    final db = await _getDb();

    int? accountId;
    await db.transaction((txn) async {
      accountId = await txn.insert(
        'Wallet',
        {
          'Name': name,
        },
      );

      final chainIds = <String>{};

      for (var publicKey in publicKeys) {
        final chainId = publicKey.chainId;

        assert(
          !chainIds.contains(chainId),
          'Duplicate chain-id "$chainId" not allowed',
        );

        if (!chainIds.contains(chainId)) {
          final publicKeyId = await txn.insert('PublicKey', {
            'WalletId': accountId,
            'Hex': publicKey.hex,
            'ChainId': chainId,
          });

          if (publicKey.chainId == selectedChainId) {
            chainIds.add(chainId);

            await txn.insert(
              'SelectedPublicKey',
              {
                'WalletId': accountId,
                'PublicKeyId': publicKeyId,
              },
            );
          }
        }
      }
    });

    Account? details;
    if (accountId != null) {
      details = await getAccount(id: accountId.toString());
    }

    return details;
  }

  Future<int> removeAccount({required String id}) async {
    final db = await _getDb();
    final count = await db.rawDelete(_sqlDeleteAccount, [id]);

    return count;
  }

  Future<int> removeAllAccounts() async {
    final db = await _getDb();
    final count = await db.rawDelete(_sqlDeleteAllAccounts);

    return count;
  }

  Future<Database> _getDb() {
    _db ??= _initDb();

    return _db!;
  }

  static Future<Database> _initDb() async {
    final database = await getDatabase();
    await database.parent.create(recursive: true);

    final db = await openDatabase(
      database.path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpdate,
    );

    return db;
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    _createV2(batch);
    await batch.commit();
  }

  static Future<void> _onUpdate(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    final batch = db.batch();
    if (oldVersion == 1 && newVersion == 2) {
      _upgradeV1toV2(
        batch,
      );
      _createV2(batch);
    }

    await batch.commit();
  }

  static void _createV2(Batch batch) {
    batch.execute(_sqlCreateTableConfig);
    batch.execute(_sqlInitConfig);
    batch.execute(_sqlCreateTableAccount);
    batch.execute(_sqlCreateTablePublicKey);
    batch.execute(_sqlCreateTableSelectedPublicKey);
  }

  static void _upgradeV1toV2(
    Batch batch,
  ) {
    batch.execute('DROP TABLE IF EXISTS Wallet');
    batch.execute('DROP TABLE IF EXISTS Config');
  }

  static Account _mapAccount(Map<String, Object?> result) {
    final id = result['Id'] as int;
    final name = result['Name'] as String;
    final hex = result['Hex'] as String;
    final chainId = result['ChainId'] as String;
    final coin = ChainId.toCoin(chainId);

    return BasicAccount(
      id: id.toString(),
      name: name,
      publicKey: PublicKey.fromCompressPublicHex(
          convert.hex.decoder.convert(hex), coin),
      linkedAccountIds: [],
    );
  }
}
