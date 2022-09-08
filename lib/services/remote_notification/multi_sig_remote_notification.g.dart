// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_remote_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigRemoteNotification _$MultiSigRemoteNotificationFromJson(
        Map<String, dynamic> json) =>
    MultiSigRemoteNotification(
      topic: MultiSigTopic.fromJson(json['topic'] as String),
      address: json['address'] as String?,
      txUuid: json['txUuid'] as String?,
      txBody: json['txBody'] as String?,
      txHash: json['txHash'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$MultiSigRemoteNotificationToJson(
        MultiSigRemoteNotification instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'address': instance.address,
      'txUuid': instance.txUuid,
      'txBody': instance.txBody,
      'txHash': instance.txHash,
      'status': instance.status,
    };
