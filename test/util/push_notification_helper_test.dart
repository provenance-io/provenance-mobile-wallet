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
