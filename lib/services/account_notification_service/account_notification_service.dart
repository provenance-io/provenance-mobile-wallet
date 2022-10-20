import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provenance_wallet/extension/list_extension.dart';
import 'package:provenance_wallet/services/account_notification_service/models/sembast_text_notification_item.dart';
import 'package:provenance_wallet/services/account_notification_service/notification_item.dart';
import 'package:provenance_wallet/util/localized_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

import 'models/sembast_id_notification_item.dart';

class AccountNotificationService implements Disposable {
  AccountNotificationService({
    bool inMemory = false,
  }) {
    _db = _initDb(
      inMemory: inMemory,
    );

    _update();
  }

  final _textStore = StoreRef<String, Map<String, Object?>?>('text');
  final _idStore = StoreRef<String, Map<String, Object?>?>('id');

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

    final model = SembastTextNotificationItem(
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

  Future<void> addText({
    required String label,
    required DateTime created,
  }) async {
    final db = await _db;

    final model = SembastTextNotificationItem(
      label: label,
      created: created,
    );

    await _textStore.add(db, model.toRecord());

    await _update();
  }

  Future<void> addId({
    required StringId id,
    required DateTime created,
  }) async {
    final db = await _db;

    final model = SembastIdNotificationItem(
      stringId: id,
      created: created,
    );

    await _idStore.add(db, model.toRecord());

    await _update();
  }

  Future<void> delete({
    required List<String> ids,
  }) async {
    final db = await _db;

    for (final id in ids) {
      await _textStore.record(id).delete(db);
      await _idStore.record(id).delete(db);
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
    final textRecords = await _textStore.find(db);

    final textResults = textRecords
        .where((e) => e.value != null)
        .map((e) => _fromTextRecord(e.key, e.value!));

    final idRecords = await _idStore.find(db);
    final idResults = idRecords
        .where((e) => e.value != null)
        .map((e) => _fromIdRecord(e.key, e.value!));

    return [
      ...textResults,
      ...idResults,
    ];
  }

  Future<void> _update() async {
    final results = await _getAll();
    results.sortDescendingBy((e) => e.created.millisecondsSinceEpoch);

    _notifications.add(results);
  }

  NotificationItem _fromTextRecord(String id, Map<String, dynamic> record) {
    final model = SembastTextNotificationItem.fromRecord(record);

    return NotificationItem(
      id: id,
      label: LocalizedString.text(model.label),
      created: model.created,
    );
  }

  NotificationItem _fromIdRecord(String id, Map<String, dynamic> record) {
    final model = SembastIdNotificationItem.fromRecord(record);

    return NotificationItem(
      id: id,
      label: LocalizedString.id(model.stringId),
      created: model.created,
    );
  }
}
