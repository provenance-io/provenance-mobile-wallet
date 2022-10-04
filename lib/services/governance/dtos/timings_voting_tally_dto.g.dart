// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timings_voting_tally_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimingsVotingTallyDto _$TimingsVotingTallyDtoFromJson(
        Map<String, dynamic> json) =>
    TimingsVotingTallyDto(
      yes: json['yes'] == null
          ? null
          : TallyAmountDto.fromJson(json['yes'] as Map<String, dynamic>),
      no: json['no'] == null
          ? null
          : TallyAmountDto.fromJson(json['no'] as Map<String, dynamic>),
      noWithVeto: json['noWithVeto'] == null
          ? null
          : TallyAmountDto.fromJson(json['noWithVeto'] as Map<String, dynamic>),
      abstain: json['abstain'] == null
          ? null
          : TallyAmountDto.fromJson(json['abstain'] as Map<String, dynamic>),
      total: json['total'] == null
          ? null
          : TallyAmountDto.fromJson(json['total'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TimingsVotingTallyDtoToJson(
        TimingsVotingTallyDto instance) =>
    <String, dynamic>{
      'yes': instance.yes,
      'no': instance.no,
      'noWithVeto': instance.noWithVeto,
      'abstain': instance.abstain,
      'total': instance.total,
    };
