import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/remote_notification/multi_sig_topic.dart';

part 'multi_sig_remote_notification.g.dart';

@JsonSerializable()
class MultiSigRemoteNotification {
  MultiSigRemoteNotification({
    required this.address,
    required this.topic,
    required this.txUuid,
    required this.txBody,
  });

  final String address;
  @JsonKey(fromJson: _topicFromJson, toJson: _topicToJson)
  final MultiSigTopic topic;
  final String txUuid;
  final String txBody;

  static MultiSigTopic _topicFromJson(String value) =>
      MultiSigTopic.values.firstWhere((e) => e.id == value);
  static String _topicToJson(MultiSigTopic topic) => topic.id;

  factory MultiSigRemoteNotification.fromJson(Map<String, dynamic> json) =>
      _$MultiSigRemoteNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigRemoteNotificationToJson(this);
}
