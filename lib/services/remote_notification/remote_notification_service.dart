import 'package:provenance_wallet/services/remote_notification/multi_sig_remote_notification.dart';

abstract class RemoteNotificationService {
  Stream<MultiSigRemoteNotification> get multiSig;

  bool isRegistered(String topic);

  Future<void> registerForPushNotifications(
    String topic,
  );

  Future<void> unregisterForPushNotifications(
    String topic,
  );
}
