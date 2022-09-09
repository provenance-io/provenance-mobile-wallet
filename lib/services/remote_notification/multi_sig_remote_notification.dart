import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/remote_notification/multi_sig_topic.dart';

part 'multi_sig_remote_notification.g.dart';

@JsonSerializable()
class MultiSigRemoteNotification {
  MultiSigRemoteNotification({
    required this.topic,
    this.address,
    this.txUuid,
    this.txBody,
    this.txHash,
    this.status,
  });

  final MultiSigTopic topic;
  final String? address;
  final String? txUuid;
  final String? txBody;
  final String? txHash;
  final String? status;

  factory MultiSigRemoteNotification.fromJson(Map<String, dynamic> json) =>
      _$MultiSigRemoteNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigRemoteNotificationToJson(this);
}
