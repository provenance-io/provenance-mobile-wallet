import 'package:provenance_wallet/services/remote_notification/multi_sig_remote_notification.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';

class DisabledRemoteNotificationService implements RemoteNotificationService {
  @override
  Stream<MultiSigRemoteNotification> get multiSig => Stream.empty();

  @override
  Future<void> registerForPushNotifications(String topic) => Future.value();

  @override
  Future<void> unregisterForPushNotifications(String topic) => Future.value();

  @override
  bool isRegistered(String topic) => false;
}
