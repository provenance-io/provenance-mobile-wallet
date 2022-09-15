import 'package:provenance_wallet/services/remote_notification/multi_sig_remote_notification_data.dart';

class MultiSigRemoteNotification {
  MultiSigRemoteNotification({
    required this.data,
    this.title,
    this.body,
  });

  final MultiSigRemoteNotificationData data;
  final String? title;
  final String? body;
}
