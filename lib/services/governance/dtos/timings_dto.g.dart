// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimingsDto _$TimingsDtoFromJson(Map<String, dynamic> json) => TimingsDto(
      deposit: json['deposit'] == null
          ? null
          : TimingsDepositDto.fromJson(json['deposit'] as Map<String, dynamic>),
      voting: json['voting'] == null
          ? null
          : TimingsVotingDto.fromJson(json['voting'] as Map<String, dynamic>),
      submitTime: json['submitTime'] == null
          ? null
          : DateTime.parse(json['submitTime'] as String),
      depositEndTime: json['depositEndTime'] == null
          ? null
          : DateTime.parse(json['depositEndTime'] as String),
      votingTime: json['votingTime'] == null
          ? null
          : VotingTimeDto.fromJson(json['votingTime'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TimingsDtoToJson(TimingsDto instance) =>
    <String, dynamic>{
      'deposit': instance.deposit,
      'voting': instance.voting,
      'submitTime': instance.submitTime?.toIso8601String(),
      'depositEndTime': instance.depositEndTime?.toIso8601String(),
      'votingTime': instance.votingTime,
    };
