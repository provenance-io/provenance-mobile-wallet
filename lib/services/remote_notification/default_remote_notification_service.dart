import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/services/remote_notification/multi_sig_remote_notification.dart';
import 'package:provenance_wallet/services/remote_notification/multi_sig_remote_notification_data.dart';
import 'package:provenance_wallet/services/remote_notification/multi_sig_topic.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/util/lazy.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/subjects.dart';

class DefaultRemoteNotificationService extends RemoteNotificationService
    implements Disposable {
  DefaultRemoteNotificationService() {
    _lazyInit = Lazy(() => _init());
  }

  final Set<String> _registrations = {};
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _multiSig = PublishSubject<MultiSigRemoteNotification>();
  static final _multiSigTopics = MultiSigTopic.values.map((e) => e.id).toSet();
  late final Lazy<Future<void>> _lazyInit;

  @override
  Stream<MultiSigRemoteNotification> get multiSig => _multiSig;

  @override
  bool isRegistered(String topic) => _registrations.contains(topic);

  ///
  /// This method runs in its own isolate outside the application context, so
  /// it is not possible to update application state or execute any UI
  /// impacting logic.
  ///
  /// See https://firebase.flutter.dev/docs/messaging/usage/#background-messages
  ///
  static void onBackgroundMultiSigNotification(
      Future<void> Function(MultiSigRemoteNotification message) callback) {
    FirebaseMessaging.onBackgroundMessage((rm) async {
      final notification = _fromMessage(rm);
      if (notification != null) {
        await callback.call(notification);
      }
    });
  }

  @override
  FutureOr onDispose() {
    _multiSig.close();
  }

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
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessage);
  }

  Future<void> _onMessage(RemoteMessage message) async {
    logDebug('Received firebase message: ${message.data}');

    final notification = _fromMessage(message);
    if (notification != null) {
      _multiSig.add(notification);
    }
  }

  static MultiSigRemoteNotification? _fromMessage(RemoteMessage message) {
    MultiSigRemoteNotification? result;

    final dataTopic = message.data['topic'] as String?;
    if (_multiSigTopics.contains(dataTopic)) {
      final data = MultiSigRemoteNotificationData.fromJson(message.data);

      result = MultiSigRemoteNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        data: data,
      );
    }

    return result;
  }
}
