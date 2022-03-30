import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationHelper {
  PushNotificationHelper(this._firebaseMessaging);

  final FirebaseMessaging _firebaseMessaging;

  Future<void> init() async {
    /// if the app is in the foreground then we do not need to show anything
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    return _firebaseMessaging
        .getToken()
        .then((value) => log("Firebase token: $value"));
  }

  Future<void> registerForTopic(String topic) {
    return _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unregisterForTopic(String topic) {
    return _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
