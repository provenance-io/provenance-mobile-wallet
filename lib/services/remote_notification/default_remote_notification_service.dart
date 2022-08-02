import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/util/lazy.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

class DefaultRemoteNotificationService extends RemoteNotificationService {
  DefaultRemoteNotificationService() {
    _lazyInit = Lazy(() => _init());
  }

  final Set<String> _registrations = {};
  final _firebaseMessaging = FirebaseMessaging.instance;
  late final Lazy<Future<void>> _lazyInit;

  @override
  bool isRegistered(String topic) => _registrations.contains(topic);

  @override
  Future<void> registerForPushNotifications(
    String topic,
  ) async {
    await _lazyInit.value;

    logDebug("Registering for $topic");

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      logDebug('Failed to register for topic: $topic');
    }

    _registrations.add(topic);
  }

  @override
  Future<void> unregisterForPushNotifications(
    String topic,
  ) async {
    await _lazyInit.value;

    logDebug("Unregistering for $topic");

    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      logDebug('Failed to unregister for topic: $topic');
    }

    _registrations.remove(topic);
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

    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onBackgroundMessage(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessage);
  }

  Future<void> _onMessage(RemoteMessage message) async {
    // TODO-Roy:
    // 1. Create a new message class that encompasses our data
    // 2. Transform RemoteMessage to that message
    // 3. Expose via a stream on this class
    logDebug('Received firebase message: $message');
  }
}
