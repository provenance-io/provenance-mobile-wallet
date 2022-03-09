import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/services/notification/notification_info.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';

class BasicNotificationService implements NotificationService, Disposable {
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
  void dismiss(String id) {
    final value = _map.remove(id);
    if (value != null) {
      _stream.add(_map.values.toList());
    }
  }

  @override
  void onDispose() {
    _map.clear();
    _stream.close();
  }
}
