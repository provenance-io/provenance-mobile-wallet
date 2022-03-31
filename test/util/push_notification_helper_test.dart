import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_wallet/util/push_notification_helper.dart';

import './push_notification_helper_test.mocks.dart';

@GenerateMocks([FirebaseMessaging])
main() {
  MockFirebaseMessaging? _mockFirebaseMessaging;
  PushNotificationHelper? _pushNotificationHelper;

  setUp(() {
    _mockFirebaseMessaging = MockFirebaseMessaging();

    _pushNotificationHelper = PushNotificationHelper(_mockFirebaseMessaging!);
  });

  test('init', () async {
    when(_mockFirebaseMessaging!.requestPermission(
      alert: anyNamed("alert"),
      announcement: anyNamed("announcement"),
      badge: anyNamed("badge"),
      carPlay: anyNamed("carPlay"),
      criticalAlert: anyNamed("criticalAlert"),
      provisional: anyNamed("provisional"),
      sound: anyNamed("sound"),
    )).thenAnswer((_) => Future.value(NotificationSettings(
          alert: AppleNotificationSetting.enabled,
          announcement: AppleNotificationSetting.enabled,
          badge: AppleNotificationSetting.enabled,
          carPlay: AppleNotificationSetting.enabled,
          lockScreen: AppleNotificationSetting.enabled,
          authorizationStatus: AuthorizationStatus.authorized,
          showPreviews: AppleShowPreviewSetting.always,
          notificationCenter: AppleNotificationSetting.enabled,
          sound: AppleNotificationSetting.enabled,
        )));

    when(_mockFirebaseMessaging!.setForegroundNotificationPresentationOptions(
      alert: anyNamed("alert"),
      badge: anyNamed("badge"),
      sound: anyNamed("sound"),
    )).thenAnswer((_) => Future.value());

    when(_mockFirebaseMessaging!.getToken())
        .thenAnswer((_) => Future.value("ABCDE"));

    await _pushNotificationHelper!.init();

    final captures = verify(
      _mockFirebaseMessaging!.setForegroundNotificationPresentationOptions(
        alert: captureAnyNamed("alert"),
        badge: captureAnyNamed("badge"),
        sound: captureAnyNamed("sound"),
      ),
    ).captured;

    expect(captures[0], false);
    expect(captures[1], false);
    expect(captures[2], false);

    final captures2 = verify(_mockFirebaseMessaging!.requestPermission(
      alert: captureAnyNamed("alert"),
      announcement: captureAnyNamed("announcement"),
      badge: captureAnyNamed("badge"),
      carPlay: captureAnyNamed("carPlay"),
      criticalAlert: captureAnyNamed("criticalAlert"),
      provisional: captureAnyNamed("provisional"),
      sound: captureAnyNamed("sound"),
    )).captured;

    expect(captures2[0], true);
    expect(captures2[1], false);
    expect(captures2[2], true);
    expect(captures2[3], false);
    expect(captures2[4], false);
    expect(captures2[5], false);
    expect(captures2[6], true);
  });

  test('registerForTopic', () async {
    when(_mockFirebaseMessaging!.subscribeToTopic(any))
        .thenAnswer((_) => Future.value());

    const topic = 'TestTopic';
    await _pushNotificationHelper!.registerForTopic(topic);

    verify(_mockFirebaseMessaging!.subscribeToTopic(topic));
  });

  test('unregisterForTopic', () async {
    when(_mockFirebaseMessaging!.unsubscribeFromTopic(any))
        .thenAnswer((_) => Future.value());

    const topic = 'TestTopic';
    await _pushNotificationHelper!.unregisterForTopic(topic);

    verify(_mockFirebaseMessaging!.unsubscribeFromTopic(topic));
  });
}
