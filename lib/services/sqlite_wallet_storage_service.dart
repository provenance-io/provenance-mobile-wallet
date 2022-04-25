import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:provenance_blockchain_wallet/chain_id.dart';
import 'package:provenance_blockchain_wallet/services/models/wallet_details.dart';
import 'package:provenance_blockchain_wallet/services/wallet_service/wallet_storage_service.dart';
import 'package:provenance_blockchain_wallet/util/logs/logging.dart';
import 'package:sqflite/sqflite.dart';

class SqliteWalletStorageService {
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
  static const _sqlCreateTableWallet = '''
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
  static const _sqlGetWallets = '''
    SELECT w.Id, w.Name, pk.Address, pk.Hex, pk.ChainId FROM Wallet w INNER JOIN PublicKey pk ON w.Id = pk.WalletId INNER JOIN SelectedPublicKey spk ON w.Id = spk.WalletId AND pk.Id = spk.PublicKeyId
  ''';
  static const _sqlGetWallet = '''
    SELECT w.Id, w.Name, pk.Address, pk.Hex, pk.ChainId FROM Wallet w INNER JOIN PublicKey pk ON w.Id = pk.WalletId INNER JOIN SelectedPublicKey spk ON w.Id = spk.WalletId AND pk.Id = spk.PublicKeyId WHERE w.Id = ?
  ''';
  static const _sqlGetSelectedWallet = '''
    SELECT w.Id, w.Name, pk.Address, pk.Hex, pk.ChainId FROM Wallet w INNER JOIN SelectedPublicKey spk on w.Id = spk.WalletId INNER JOIN PublicKey pk on pk.Id = spk.PublicKeyId AND pk.Id = spk.PublicKeyId INNER JOIN Config c ON w.Id = c.SelectedId
  ''';
  static const _sqlGetFirstWallet = '''
    SELECT w.Id, w.Name, pk.Address, pk.Hex, pk.ChainId FROM Wallet w INNER JOIN PublicKey pk ON w.Id = pk.WalletId ORDER BY w.Id LIMIT 1
  ''';
  static const _sqlUpdateSelectedWallet = '''
    UPDATE Config SET SelectedId = ? WHERE Id = 1
  ''';
  static const _sqlRenameWallet = '''
    UPDATE Wallet SET Name = ? WHERE Id = ?
  ''';
  static const _sqlDeleteWallet = '''
    DELETE FROM Wallet WHERE Id = ?;
    DELETE FROM PublicKey WHERE WalletId = ?;
    DELETE FROM SelectedPublicKey WHERE WalletId = ?;
  ''';
  static const _sqlDeleteAllWallets = '''
    DELETE FROM Wallet;
    DELETE FROM PublicKey;
    DELETE FROM SelectedPublicKey;
  ''';

  static Future<Database>? _db;

  Future<List<WalletDetails>> getWallets() async {
    final db = await _getDb();
    final results = await db.rawQuery(_sqlGetWallets);
    final details = results.map(_mapWallet).toList();

    return details;
  }

  Future<WalletDetails?> getWallet({required String id}) async {
    final db = await _getDb();
    final results = await db.rawQuery(_sqlGetWallet, [id]);

    WalletDetails? wallet;
    if (results.isNotEmpty) {
      wallet = _mapWallet(results[0]);
    }

    return wallet;
  }

  Future<WalletDetails?> getSelectedWallet() async {
    final db = await _getDb();
    final results = await db.rawQuery(_sqlGetSelectedWallet);

    WalletDetails? wallet;
    if (results.isNotEmpty) {
      wallet = _mapWallet(results[0]);
    }

    return wallet;
  }

  Future<WalletDetails?> selectWallet({String? id}) async {
    final db = await _getDb();

    if (id == null) {
      final results = await db.rawQuery(_sqlGetFirstWallet);
      if (results.isNotEmpty) {
        id = (results[0]['Id'] as int).toString();
      }
    }

    await db.execute(_sqlUpdateSelectedWallet, [id]);

    return getSelectedWallet();
  }

  Future<WalletDetails?> renameWallet({
    required String id,
    required String name,
  }) async {
    final db = await _getDb();
    int _ = await db.rawUpdate(_sqlRenameWallet, [name, id]);

    return await getWallet(id: id);
  }

  Future<WalletDetails?> setChainId({
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

    WalletDetails? details;

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
        details = await getWallet(id: id);
      }
    }

    return details;
  }

  Future<WalletDetails?> addWallet({
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

    int? walletId;
    await db.transaction((txn) async {
      walletId = await txn.insert(
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
            'WalletId': walletId,
            'Address': publicKey.address,
            'Hex': publicKey.hex,
            'ChainId': chainId,
          });

          if (publicKey.chainId == selectedChainId) {
            chainIds.add(chainId);

            await txn.insert(
              'SelectedPublicKey',
              {
                'WalletId': walletId,
                'PublicKeyId': publicKeyId,
              },
            );
          }
        }
      }
    });

    WalletDetails? details;
    if (walletId != null) {
      details = await getWallet(id: walletId.toString());
    }

    return details;
  }

  Future<int> removeWallet({required String id}) async {
    final db = await _getDb();
    final count = await db.rawDelete(_sqlDeleteWallet, [id]);

    return count;
  }

  Future<int> removeAllWallets() async {
    final db = await _getDb();
    final count = await db.rawDelete(_sqlDeleteAllWallets);

    return count;
  }

  Future<Database> _getDb() {
    _db ??= _initDb();

    return _db!;
  }

  static Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, _name);

    await Directory(databasePath).create(recursive: true);

    final db = await openDatabase(
      path,
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
    batch.execute(_sqlCreateTableWallet);
    batch.execute(_sqlCreateTablePublicKey);
    batch.execute(_sqlCreateTableSelectedPublicKey);
  }

  static void _upgradeV1toV2(
    Batch batch,
  ) {
    batch.execute('DROP TABLE IF EXISTS Wallet');
    batch.execute('DROP TABLE IF EXISTS Config');
  }

  static WalletDetails _mapWallet(Map<String, Object?> result) {
    final id = result['Id'] as int;
    final name = result['Name'] as String;
    final address = result['Address'] as String;
    final publicKey = result['Hex'] as String;
    final chainId = result['ChainId'] as String;
    final coin = ChainId.toCoin(chainId);

    return WalletDetails(
      id: id.toString(),
      address: address,
      name: name,
      publicKey: publicKey,
      coin: coin,
    );
  }
}
