import 'package:provenance_wallet/services/notification/client_notification_mixin.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/push_notification_helper.dart';

class DefaultRemoteNotificationService extends RemoteNotificationService
    with ClientNotificationMixin {
  DefaultRemoteNotificationService(this._pushNotificationHelper);

  final PushNotificationHelper _pushNotificationHelper;

  @override
  Future<void> registerForPushNotifications(
    String topic,
  ) async {
    logDebug("Registering for $topic");
    await _pushNotificationHelper.registerForTopic(topic);
  }

  @override
  Future<void> unregisterForPushNotifications(
    String topic,
  ) async {
    logDebug("Unregistering for $topic");
    await _pushNotificationHelper.unregisterForTopic(topic);
  }
}
