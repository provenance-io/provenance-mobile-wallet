abstract class RemoteNotificationService {
  bool isRegistered(String topic);

  Future<void> registerForPushNotifications(
    String topic,
  );

  Future<void> unregisterForPushNotifications(
    String topic,
  );
}
