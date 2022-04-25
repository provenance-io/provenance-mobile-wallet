import 'package:provenance_blockchain_wallet/services/models/base_response.dart';
import 'package:provenance_blockchain_wallet/services/notification/notification_group.dart';
import 'package:provenance_blockchain_wallet/services/notification/notification_service.dart';
import 'package:provenance_blockchain_wallet/util/get.dart';
import 'package:uuid/uuid.dart';

mixin ClientNotificationMixin on Object {
  final _notificationService = get<NotificationService>();
  final _id = Uuid().v1().toString();

  void notifyOnError(BaseResponse response) {
    if (response.isServiceDown) {
      _notificationService.notifyGrouped(
        NotificationGroup.serviceError,
        _id,
      );
    } else if (response.isSuccessful) {
      _notificationService.dismissGrouped(
        NotificationGroup.serviceError,
        _id,
      );
    }
  }
}
