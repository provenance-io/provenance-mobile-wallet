import 'package:provenance_wallet/util/localized_string.dart';

class SembastIdNotificationItem {
  const SembastIdNotificationItem({
    required this.stringId,
    required this.created,
  });

  final StringId stringId;
  final DateTime created;

  Map<String, dynamic> toRecord() => {
        'stringId': stringId.name,
        'created': created.millisecondsSinceEpoch,
      };

  // ignore: unused_element
  factory SembastIdNotificationItem.fromRecord(Map<String, dynamic> rec) =>
      SembastIdNotificationItem(
        stringId: StringId.values.byName(rec['stringId'] as String),
        created: DateTime.fromMillisecondsSinceEpoch(rec['created'] as int),
      );
}
