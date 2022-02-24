import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:sqflite/sqflite.dart';

class SqliteWalletStorageService {
  static const _version = 1;
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
      "Name"	TEXT,
      "Address"	TEXT,
      "PublicKey"	TEXT,
      "IsMainNet"	INTEGER,
      PRIMARY KEY("Id" AUTOINCREMENT)
    );
  ''';
  static const _sqlGetWallets = '''
    SELECT * FROM Wallet
  ''';
  static const _sqlGetWallet = '''
    SELECT * FROM Wallet WHERE Id = ?
  ''';
  static const _sqlGetSelectedWallet = '''
    SELECT w.* FROM Wallet w INNER JOIN Config c ON w.Id = c.SelectedId
  ''';
  static const _sqlGetFirstWallet = '''
    SELECT * FROM Wallet ORDER BY Id LIMIT 1
  ''';
  static const _sqlUpdateSelectedWallet = '''
    UPDATE Config SET SelectedId = ? WHERE Id = 1
  ''';
  static const _sqlRenameWallet = '''
    UPDATE Wallet SET Name = ? WHERE Id = ?
  ''';
  static const _sqlDeleteWallet = '''
    DELETE FROM Wallet WHERE Id = ?
  ''';
  static const _sqlDeleteAllWallets = '''
    DELETE FROM Wallet
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

  Future<String> addWallet({
    required String name,
    required String address,
    required String publicKey,
    required Coin coin,
  }) async {
    final db = await _getDb();
    final id = await db.insert(
      'wallet',
      {
        'Name': name,
        'Address': address,
        'PublicKey': publicKey,
        'IsMainNet': coin == Coin.mainNet ? 1 : 0,
      },
    );

    final selectedWallet = await getSelectedWallet();
    if (selectedWallet == null) {
      await selectWallet(
        id: id.toString(),
      );
    }

    return id.toString();
  }

  Future removeWallet({required String id}) async {
    final db = await _getDb();
    await db.execute(_sqlDeleteWallet, [id]);
    await selectWallet();
  }

  Future removeAllWallets() async {
    final db = await _getDb();
    await db.execute(_sqlDeleteAllWallets);
    await selectWallet();
  }

  Future<Database> _getDb() {
    _db ??= _initDb();

    return _db!;
  }

  static Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, _name);

    await Directory(databasePath).create(recursive: true);

    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute(_sqlCreateTableConfig);
    await db.execute(_sqlInitConfig);
    await db.execute(_sqlCreateTableWallet);
  }

  static WalletDetails _mapWallet(Map<String, Object?> result) {
    final id = result['Id'] as int;
    final name = result['Name'] as String;
    final address = result['Address'] as String;
    final publicKey = result['PublicKey'] as String;
    final isMainNet = result['IsMainNet'] as int == 1;

    return WalletDetails(
      id: id.toString(),
      address: address,
      name: name,
      publicKey: publicKey,
      coin: (isMainNet)? Coin.mainNet : Coin.testNet,
    );
  }
}
