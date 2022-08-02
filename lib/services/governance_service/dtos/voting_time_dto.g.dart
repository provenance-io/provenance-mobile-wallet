// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voting_time_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VotingTimeDto _$VotingTimeDtoFromJson(Map<String, dynamic> json) =>
    VotingTimeDto(
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
    );

Map<String, dynamic> _$VotingTimeDtoToJson(VotingTimeDto instance) =>
    <String, dynamic>{
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
    };
