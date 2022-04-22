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
    when(_mockFirebaseMessaging!.subscribeToTopic(any))
        .thenAnswer((_) => Future.value());
    const enabled = AppleNotificationSetting.enabled;
    when(_mockFirebaseMessaging!.requestPermission()).thenAnswer(
      (_) => Future.value(
        NotificationSettings(
          alert: enabled,
          announcement: enabled,
          authorizationStatus: AuthorizationStatus.authorized,
          badge: enabled,
          carPlay: enabled,
          lockScreen: enabled,
          notificationCenter: enabled,
          showPreviews: AppleShowPreviewSetting.always,
          sound: AppleNotificationSetting.enabled,
        ),
      ),
    );
    when(_mockFirebaseMessaging!.setForegroundNotificationPresentationOptions())
        .thenAnswer((_) => Future.value());
    when(_mockFirebaseMessaging!.getToken())
        .thenAnswer((_) => Future.value(null));

    _pushNotificationHelper = PushNotificationHelper(_mockFirebaseMessaging!);
  });

  test('registerForTopic', () async {
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
