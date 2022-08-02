import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';

class DisabledRemoteNotificationService implements RemoteNotificationService {
  @override
  Future<void> registerForPushNotifications(String topic) => Future.value();

  @override
  Future<void> unregisterForPushNotifications(String topic) => Future.value();

  @override
  bool isRegistered(String topic) => false;
}
