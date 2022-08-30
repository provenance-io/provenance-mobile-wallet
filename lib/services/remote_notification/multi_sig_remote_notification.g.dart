// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_remote_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigRemoteNotification _$MultiSigRemoteNotificationFromJson(
        Map<String, dynamic> json) =>
    MultiSigRemoteNotification(
      address: json['address'] as String,
      topic: MultiSigRemoteNotification._topicFromJson(json['topic'] as String),
      txUuid: json['txUuid'] as String,
      txBody: json['txBody'] as String,
    );

Map<String, dynamic> _$MultiSigRemoteNotificationToJson(
        MultiSigRemoteNotification instance) =>
    <String, dynamic>{
      'address': instance.address,
      'topic': MultiSigRemoteNotification._topicToJson(instance.topic),
      'txUuid': instance.txUuid,
      'txBody': instance.txBody,
    };
