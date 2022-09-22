import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/extension/wallet_connect_address_helper.dart';
import 'package:provenance_wallet/mixin/listenable_mixin.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/models/wallet_connect_queue_group.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/session_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/sign_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/tx_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/wallet_connect_action.dart';
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

  Future<void> createWalletConnectSessionGroup(
      WalletConnectAddress connectAddress,
      String walletAddress,
      ClientMeta? clientMeta) async {
    final group = WalletConnectQueueGroup(
      connectAddress: connectAddress,
      accountAddress: walletAddress,
      clientMeta: clientMeta,
    );
    final record = _main.record(connectAddress.fullUriString);

    final db = await _db;

    await record.add(db, group.toRecord());
  }

  Future<void> removeWalletConnectSessionGroup(
      WalletConnectAddress address) async {
    final record = _main.record(address.fullUriString);

    final db = await _db;
    await record.delete(db);
    notifyListeners();
  }

  Future<void> updateConnectionDetails(
      WalletConnectAddress address, ClientMeta clientMeta) async {
    final record = _main.record(address.fullUriString);

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

  Future<void> addWalletConnectSignRequest(
      WalletConnectAddress address, SignAction signRequest) async {
    final record = _main.record(address.fullUriString);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return;
    }

    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup[signRequest.id] = signRequest;

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<void> addWalletConnectSendRequest(
      WalletConnectAddress address, TxAction sendRequest) async {
    final record = _main.record(address.fullUriString);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return;
    }

    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup[sendRequest.id] = sendRequest;

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<void> addWalletApproveRequest(
      WalletConnectAddress address, SessionAction approveRequestData) async {
    final record = _main.record(address.fullUriString);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return;
    }
    final group = WalletConnectQueueGroup.fromRecord(map);
    group.actionLookup[approveRequestData.id] = approveRequestData;

    await record.update(db, group.toRecord());

    notifyListeners();
  }

  Future<WalletConnectQueueGroup?> loadGroup(
      WalletConnectAddress address) async {
    final db = await _db;
    final record = _main.record(address.fullUriString);
    final map = await record.get(db);
    if (map == null) {
      return null;
    }
    return WalletConnectQueueGroup.fromRecord(map);
  }

  Future<WalletConnectAction?> loadQueuedAction(
      WalletConnectAddress address, String requestId) async {
    final record = _main.record(address.fullUriString);

    final db = await _db;
    final map = await record.get(db);
    if (map == null) {
      return null;
    }
    final group = WalletConnectQueueGroup.fromRecord(map);
    return group.actionLookup[requestId];
  }

  Future<void> removeRequest(
      WalletConnectAddress connectAddress, String requestId) async {
    final record = _main.record(connectAddress.fullUriString);

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
    final values = await _main.find(db);

    return values
        .map((e) => WalletConnectQueueGroup.fromRecord(e.value))
        .toList();
  }

  @override
  FutureOr onDispose() {
    return close();
  }
}
