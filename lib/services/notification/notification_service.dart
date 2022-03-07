import 'package:provenance_wallet/services/notification/notification_info.dart';
import 'package:rxdart/streams.dart';

abstract class NotificationService {
  NotificationService._();

  ValueStream<List<NotificationInfo>> get notifications;

  void notify(NotificationInfo notification);

  void dismiss(String id);
}
