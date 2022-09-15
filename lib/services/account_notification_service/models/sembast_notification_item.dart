class SembastNotificationItem {
  const SembastNotificationItem({
    required this.label,
    required this.created,
  });

  final String label;
  final DateTime created;

  Map<String, dynamic> toRecord() => {
        'label': label,
        'created': created.millisecondsSinceEpoch,
      };

  // ignore: unused_element
  factory SembastNotificationItem.fromRecord(Map<String, dynamic> rec) =>
      SembastNotificationItem(
        label: rec['label'] as String,
        created: DateTime.fromMillisecondsSinceEpoch(rec['created'] as int),
      );
}
