import 'package:provenance_wallet/services/models/base_response.dart';
import 'package:provenance_wallet/services/notification/notification_info.dart';
import 'package:provenance_wallet/services/notification/notification_kind.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

mixin ClientNotificationMixin on Object {
  final _notificationService = get<NotificationService>();

  void notifyOnError(BaseResponse response, String clientId) {
    if (response.isServiceDown) {
      final notification = NotificationInfo(
        id: clientId,
        title: Strings.notifyServiceErrorTitle,
        message: Strings.notifyServiceErrorMessage,
        kind: NotificationKind.warn,
      );

      _notificationService.notify(notification);
    } else if (response.isSuccessful) {
      _notificationService.dismiss(clientId);
    }
  }
}
