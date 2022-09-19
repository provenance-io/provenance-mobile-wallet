class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.label,
    required this.created,
  });

  final String id;
  final String label;
  final DateTime created;
}
