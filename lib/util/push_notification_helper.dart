import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

class PushNotificationHelper {
  PushNotificationHelper(this._firebaseMessaging);

  final FirebaseMessaging _firebaseMessaging;

  Future<void> init() async {
    await _firebaseMessaging.requestPermission(alert: true);

    /// if the app is in the foreground then we do not need to show anything
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    try {
      final token = await _firebaseMessaging.getToken();

      print('Firebase token: $token');
    } on Exception catch (e) {
      logError(
        'Failed to get Firebase token',
        error: e,
      );
    }
  }

  Future<void> registerForTopic(String topic) {
    return _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unregisterForTopic(String topic) {
    return _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
