import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/services/notification/notification_group.dart';
import 'package:provenance_wallet/services/notification/notification_info.dart';
import 'package:provenance_wallet/services/notification/notification_kind.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';

class BasicNotificationService implements NotificationService, Disposable {
  final _grouped = <String, Set<String>>{};
  final _map = <String, NotificationInfo>{};
  final _stream = BehaviorSubject<List<NotificationInfo>>.seeded([]);

  @override
  ValueStream<List<NotificationInfo>> get notifications => _stream;

  @override
  void notify(NotificationInfo notification) {
    _map[notification.id] = notification;
    _stream.add(_map.values.toList());
  }

  @override
  void notifyGrouped(NotificationGroup group, String instanceId) {
    if (!_grouped.containsKey(group.name)) {
      _grouped[group.name] = {};
    }

    _grouped[group.name]!.add(instanceId);

    final count = _grouped[group.name]!.length;

    final info = _createGroup(group, count);

    _map[group.name] = info;
    _stream.add(_map.values.toList());
  }

  @override
  void dismiss(String id) {
    _map.remove(id);
    _grouped.remove(id);
    _stream.add(_map.values.toList());
  }

  @override
  void dismissGrouped(NotificationGroup group, String id) {
    final ids = _grouped[group.name];

    if (ids != null) {
      ids.remove(id);
      final count = ids.length;
      if (count == 0) {
        _grouped.remove(group.name);
        dismiss(group.name);
      } else {
        _map[group.name] = _createGroup(group, count);
        _stream.add(_map.values.toList());
      }
    }
  }

  @override
  void onDispose() {
    _map.clear();
    _stream.close();
  }

  NotificationInfo _createGroup(NotificationGroup group, int count) {
    NotificationInfo info;
    switch (group) {
      case NotificationGroup.serviceError:
        info = NotificationInfo(
          id: group.name,
          title: Strings.notifyServiceErrorTitle,
          message: Strings.notifyServiceErrorMessage,
          kind: NotificationKind.warn,
          count: count,
        );
        break;
    }

    return info;
  }
}
