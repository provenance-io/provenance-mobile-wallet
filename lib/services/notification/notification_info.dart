import 'package:provenance_wallet/services/notification/notification_kind.dart';

class NotificationInfo {
  NotificationInfo({
    required this.id,
    required this.title,
    required this.kind,
    this.message,
  });

  final String id;
  final String title;
  final NotificationKind kind;
  final String? message;
}
