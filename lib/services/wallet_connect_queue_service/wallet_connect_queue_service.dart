import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/mixin/listenable_mixin.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/models/wallet_connect_queue_group.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/session_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/sign_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/tx_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/wallet_connect_action.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:sembast/sembast.dart';

class WalletConnectQueueService extends Listenable
    with ListenableMixin
    implements Disposable {
  static const version = 1;
  static const fileName = 'wallet_connect_queue.db';

  final DatabaseFactory _factory;
  final StoreRef<String, Map<String, dynamic>> _main =
      StoreRef<String, Map<String, dynamic>>.main();

  late final Future<Database> _db;

  WalletConnectQueueService({
    required DatabaseFactory factory,
    required String directory,
    Map<dynamic, dynamic>? import,
  }) : _factory = factory {
    final path = p.join(directory, fileName);
    _db = _initDb(path, factory, import);
  }

  Future<Database> _initDb(String dbPath, DatabaseFactory factory,
      Map<dynamic, dynamic>? import) async {
    final db = await _factory.openDatabase(
      dbPath,
      version: version,
      onVersionChanged: _onVersionChanged,
    );

    return db;
  }

  Future<void> _onVersionChanged(
      Database db, int oldVersion, int newVersion) async {}

  Future<void> close() async {
    final db = await _db;
    await db.close();
  }

  Future<void> createWalletConnectSessionGroup({
    required String accountId,
    required ClientMeta? clientMeta,
  }) async {
    final group = WalletConnectQueueGroup(
      accountId: accountId,
      clientMeta: clientMeta,
    );
    final record = _main.record(accountId);

    final db = await _db;

    await record.add(db, group.toRecord());
  }

  Future<void> removeWalletConnectSessionGroup({
    required String accountId,
  }) async {
    final record = _main.record(accountId);

    final db = await _db;
    await record.delete(db);
    notifyListeners();
  }

  Future<void> updateConnectionDetails({
    required String accountId,
    required ClientMeta clientMeta,
  }) async {
    final record = _main.record(accountId);

    final db = await _db;
    final map = await record.get(db);

    if (map == null) {
      return;
    }

    final group = WalletConnectQueueGroup.fromRecord(map).copyWith(
      clientMeta: clientMeta,
    );

    await record.update(db, group.toRecord());
  }

  Future<void> addWalletConnectSignRequest({
    required String accountId,
    required SignAction signAction,
  }) async {
    final record = _main.record(accountId);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return;
    }

    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup[signAction.id] = signAction;

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<void> addWalletConnectTxRequest({
    required String accountId,
    required TxAction txAction,
  }) async {
    final record = _main.record(accountId);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return;
    }

    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup[txAction.id] = txAction;

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<void> addWalletApproveRequest({
    required String accountId,
    required SessionAction action,
  }) async {
    final record = _main.record(accountId);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return;
    }
    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup[action.id] = action;

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<WalletConnectQueueGroup?> loadGroup({
    required String accountId,
  }) async {
    final db = await _db;
    final record = _main.record(accountId);
    final map = await record.get(db);
    if (map == null) {
      return null;
    }
    return WalletConnectQueueGroup.fromRecord(map);
  }

  Future<WalletConnectAction?> loadQueuedAction({
    required String accountId,
    required String requestId,
  }) async {
    final record = _main.record(accountId);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return null;
    }
    final group = WalletConnectQueueGroup.fromRecord(map);
    return group.actionLookup[requestId];
  }

  Future<void> removeRequest({
    required String accountId,
    required String requestId,
  }) async {
    final record = _main.record(accountId);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return;
    }
    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup.remove(requestId);

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<List<WalletConnectQueueGroup>> loadAllGroups() async {
    final db = await _db;
    final snapshots = await _main.find(db);

    final groups = <WalletConnectQueueGroup>[];

    for (final snapshot in snapshots) {
      try {
        final group = WalletConnectQueueGroup.fromRecord(snapshot.value);
        groups.add(group);
      } catch (e) {
        // If schema changes, discard old records.
        logDebug('Deleting invalid record: ${snapshot.value}');

        await snapshot.ref.delete(db);
      }
    }

    return groups;
  }

  @override
  FutureOr onDispose() {
    return close();
  }
}
