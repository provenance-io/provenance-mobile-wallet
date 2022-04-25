import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:provenance_blockchain_wallet/util/lazy.dart';
import 'package:provenance_blockchain_wallet/util/logs/logging.dart';

class PushNotificationHelper {
  PushNotificationHelper(this._firebaseMessaging) {
    _lazyInit = Lazy(() => _init());
  }

  final FirebaseMessaging _firebaseMessaging;
  late final Lazy<Future<void>> _lazyInit;

  Future<void> registerForTopic(String topic) async {
    await _lazyInit.value;

    return _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unregisterForTopic(String topic) async {
    await _lazyInit.value;

    return _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<void> _init() async {
    await _firebaseMessaging.requestPermission(alert: true);

    /// if the app is in the foreground then we do not need to show anything
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    try {
      final token = await _firebaseMessaging.getToken();

      if (kDebugMode) {
        print('Firebase token: $token');
      }
    } on Exception catch (e) {
      logError(
        'Failed to get Firebase token',
        error: e,
      );
    }
  }
}
