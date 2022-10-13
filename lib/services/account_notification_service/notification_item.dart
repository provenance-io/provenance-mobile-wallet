import 'package:provenance_wallet/util/localized_string.dart';

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.label,
    required this.created,
  });

  final String id;
  final LocalizedString label;
  final DateTime created;
}
