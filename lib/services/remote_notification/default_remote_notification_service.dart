import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/push_notification_helper.dart';

class DefaultRemoteNotificationService extends RemoteNotificationService {
  DefaultRemoteNotificationService(this._pushNotificationHelper);

  final Set<String> _registrations = {};
  final PushNotificationHelper _pushNotificationHelper;

  @override
  bool isRegistered(String topic) => _registrations.contains(topic);

  @override
  Future<void> registerForPushNotifications(
    String topic,
  ) async {
    logDebug("Registering for $topic");

    try {
      await _pushNotificationHelper.registerForTopic(topic);
    } catch (e) {
      logDebug('Failed to register for topic: $topic');
    }

    _registrations.add(topic);
  }

  @override
  Future<void> unregisterForPushNotifications(
    String topic,
  ) async {
    logDebug("Unregistering for $topic");

    try {
      await _pushNotificationHelper.unregisterForTopic(topic);
    } catch (e) {
      logDebug('Failed to unregister for topic: $topic');
    }

    _registrations.remove(topic);
  }
}
