import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:provenance_wallet/services/remote_notification/default_remote_notification_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/push_notification_helper.dart';

import './default_remote_notification_service_test.mocks.dart';

@GenerateMocks([PushNotificationHelper, NotificationService])
main() {
  MockPushNotificationHelper? mockPushNotificationHelper;
  MockNotificationService? mockNotificationService;
  DefaultRemoteNotificationService? remoteNotificationService;

  setUp(() {
    mockNotificationService = MockNotificationService();
    get.registerSingleton<NotificationService>(mockNotificationService!);
    mockPushNotificationHelper = MockPushNotificationHelper();
    remoteNotificationService =
        DefaultRemoteNotificationService(mockPushNotificationHelper!);
  });

  tearDown(() {
    get.unregister<NotificationService>();
  });

  test('registerForPushNotifications', () async {
    when(mockPushNotificationHelper!.registerForTopic(any))
        .thenAnswer((_) => Future.value());

    const topic = "TestTopic";
    await remoteNotificationService!.registerForPushNotifications(topic);
    verify(mockPushNotificationHelper!.registerForTopic(topic));
  });

  test('unregisterForPushNotifications', () async {
    when(mockPushNotificationHelper!.unregisterForTopic(any))
        .thenAnswer((_) => Future.value());

    const topic = "TestTopic";
    await remoteNotificationService!.unregisterForPushNotifications(topic);
    verify(mockPushNotificationHelper!.unregisterForTopic(topic));
  });
}
