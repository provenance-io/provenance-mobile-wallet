import 'package:collection/collection.dart';

enum MultiSigStatus {
  pending('PENDING'),
  ready('READY'),
  success('SUCCESS'),
  failed('FAILED'),
  unknown('UNKNOWN'); // In case the service adds a new status.

  const MultiSigStatus(this.id);

  final String id;

  factory MultiSigStatus.fromJson(String json) =>
      MultiSigStatus.values.firstWhereOrNull((e) => e.id == json) ??
      MultiSigStatus.unknown;

  String toJson() => id;
}
