import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/services/notification/basic_notification_service.dart';
import 'package:provenance_wallet/services/notification/notification_group.dart';
import 'package:provenance_wallet/services/notification/notification_info.dart';
import 'package:provenance_wallet/services/notification/notification_kind.dart';

Matcher _notificationMatcher(int count) {
  return predicate((args) {
    final notificationInfo = args as NotificationInfo;
    expect(
      notificationInfo.id,
      NotificationGroup.serviceError.name,
    );
    expect(
      notificationInfo.title,
      BasicNotificationServiceStrings.notifyServiceErrorTitle,
    );
    expect(
      notificationInfo.message,
      BasicNotificationServiceStrings.notifyServiceErrorMessage,
    );
    expect(
      notificationInfo.kind,
      NotificationKind.warn,
    );
    expect(
      notificationInfo.count,
      count,
    );

    return true;
  });
}

main() {
  final notification1 = NotificationInfo(
    id: "1",
    title: BasicNotificationServiceStrings.notifyServiceErrorTitle,
    kind: NotificationKind.warn,
  );
  final notification2 = NotificationInfo(
    id: "2",
    title: BasicNotificationServiceStrings.notifyServiceErrorTitle,
    kind: NotificationKind.warn,
  );
  final notification3 = NotificationInfo(
    id: "1",
    title: BasicNotificationServiceStrings.notifyServiceErrorTitle,
    kind: NotificationKind.warn,
  );

  BasicNotificationService? notificationService;

  setUp(() {
    notificationService = BasicNotificationService();
  });

  group("notify", () {
    test('post notification', () async {
      expectLater(
        notificationService!.notifications,
        emitsInOrder(
          [
            [],
            [notification1],
            [notification1, notification2],
            [notification3, notification2],
          ],
        ),
      );

      notificationService!.notify(notification1);
      notificationService!.notify(notification2);
      notificationService!.notify(notification3);
    });
  });

  group("dismiss", () {
    test('dismiss notification', () async {
      notificationService!.notify(notification3);
      notificationService!.notify(notification2);

      expectLater(
        notificationService!.notifications,
        emitsInOrder(
          [
            [notification3, notification2],
            [notification2],
            [],
          ],
        ),
      );
      notificationService!.dismiss(notification3.id);
      notificationService!.dismiss(notification2.id);
    });
  });

  group("notifyGrouped", () {
    test('post grouped', () async {
      expectLater(
        notificationService!.notifications,
        emitsInOrder(
          [
            [],
            [
              _notificationMatcher(1),
            ],
            [
              _notificationMatcher(2),
            ],
            [
              _notificationMatcher(2),
            ],
          ],
        ),
      );

      notificationService!
          .notifyGrouped(NotificationGroup.serviceError, "Inst1");

      notificationService!
          .notifyGrouped(NotificationGroup.serviceError, "Inst2");

      notificationService!
          .notifyGrouped(NotificationGroup.serviceError, "Inst1");
    });

    test('post duplicte', () async {
      expectLater(
        notificationService!.notifications,
        emitsInOrder(
          [
            [],
            [
              _notificationMatcher(1),
            ],
            [
              _notificationMatcher(1),
            ],
          ],
        ),
      );

      notificationService!
          .notifyGrouped(NotificationGroup.serviceError, "Inst1");

      notificationService!
          .notifyGrouped(NotificationGroup.serviceError, "Inst1");
    });
  });

  group("dismissGrouped", () {
    test('remove group grouped', () async {
      notificationService!
          .notifyGrouped(NotificationGroup.serviceError, "Inst1");

      notificationService!
          .notifyGrouped(NotificationGroup.serviceError, "Inst2");

      expectLater(
        notificationService!.notifications,
        emitsInOrder(
          [
            [
              _notificationMatcher(2),
            ],
            [
              _notificationMatcher(1),
            ],
            [],
          ],
        ),
      );

      notificationService!
          .dismissGrouped(NotificationGroup.serviceError, "Inst2");

      notificationService!
          .dismissGrouped(NotificationGroup.serviceError, "Inst1");
    });

    test('remove duplicate', () async {
      notificationService!
          .notifyGrouped(NotificationGroup.serviceError, "Inst1");
      notificationService!
          .notifyGrouped(NotificationGroup.serviceError, "Inst2");

      expectLater(
        notificationService!.notifications,
        emitsInOrder(
          [
            [
              _notificationMatcher(2),
            ],
            [
              _notificationMatcher(1),
            ],
            [
              _notificationMatcher(1),
            ],
            [],
          ],
        ),
      );

      notificationService!
          .dismissGrouped(NotificationGroup.serviceError, "Inst2");

      notificationService!.dismissGrouped(
        NotificationGroup.serviceError,
        "Inst2",
      ); // triggers another notification, but the count does not change

      notificationService!
          .dismissGrouped(NotificationGroup.serviceError, "Inst1");
    });
  });
}
