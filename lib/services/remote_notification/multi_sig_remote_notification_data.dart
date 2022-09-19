import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/remote_notification/multi_sig_topic.dart';

part 'multi_sig_remote_notification_data.g.dart';

@JsonSerializable()
class MultiSigRemoteNotificationData {
  MultiSigRemoteNotificationData({
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

  factory MultiSigRemoteNotificationData.fromJson(Map<String, dynamic> json) =>
      _$MultiSigRemoteNotificationDataFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigRemoteNotificationDataToJson(this);
}
