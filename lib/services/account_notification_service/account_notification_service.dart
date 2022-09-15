import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provenance_wallet/services/account_notification_service/models/sembast_notification_item.dart';
import 'package:provenance_wallet/services/account_notification_service/notification_item.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

class AccountNotificationService implements Disposable {
  AccountNotificationService({
    bool inMemory = false,
  }) {
    _db = _initDb(
      inMemory: inMemory,
    );

    _update();
  }

  final _main = StoreRef<String, Map<String, Object?>?>.main();
  late final Future<Database> _db;

  ValueStream<List<NotificationItem>> get notifications => _notifications;
  final _notifications = BehaviorSubject<List<NotificationItem>>();

  static Future<void> addInBackground({
    required String label,
    required DateTime created,
  }) async {
    final db = await _initDb(
      inMemory: false,
    );

    final model = SembastNotificationItem(
      label: label,
      created: created,
    );

    final main = StoreRef<String, Map<String, Object?>?>.main();

    await main.add(db, model.toRecord());
  }

  @override
  FutureOr onDispose() {
    _notifications.close();
  }

  Future<void> add({
    required String label,
    required DateTime created,
  }) async {
    final db = await _db;

    final model = SembastNotificationItem(
      label: label,
      created: created,
    );

    await _main.add(db, model.toRecord());

    await _update();
  }

  Future<void> delete({
    required List<String> ids,
  }) async {
    final db = await _db;

    for (final id in ids) {
      final ref = _main.record(id);
      await ref.delete(db);
    }

    await _update();
  }

  static Future<Database> _initDb({
    required bool inMemory,
  }) async {
    String path;
    DatabaseFactory factory;
    if (inMemory) {
      path = sembastInMemoryDatabasePath;
      factory = databaseFactoryMemory;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      await directory.create(recursive: true);

      path = p.join(directory.path, 'account_notification_service.db');
      factory = databaseFactoryIo;
    }

    final db = await factory.openDatabase(
      path,
      version: 1,
    );

    return db;
  }

  Future<List<NotificationItem>> _getAll() async {
    final db = await _db;
    final records = await _main.find(db);

    final results = records
        .where((e) => e.value != null)
        .map((e) => _fromRecord(e.key, e.value!))
        .toList();

    return results;
  }

  Future<void> _update() async {
    final results = await _getAll();

    _notifications.add(results);
  }

  NotificationItem _fromRecord(String id, Map<String, dynamic> record) {
    final model = SembastNotificationItem.fromRecord(record);

    return NotificationItem(
      id: id,
      label: model.label,
      created: model.created,
    );
  }
}
