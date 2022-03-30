abstract class RemoteNotificationService {
  Future<void> registerForPushNotifications(
    String topic,
  );

  Future<void> unregisterForPushNotifications(
    String topic,
  );
}
