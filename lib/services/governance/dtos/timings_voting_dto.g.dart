// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timings_voting_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimingsVotingDto _$TimingsVotingDtoFromJson(Map<String, dynamic> json) =>
    TimingsVotingDto(
      params: json['params'] == null
          ? null
          : TimingsVotingParamsDto.fromJson(
              json['params'] as Map<String, dynamic>),
      tally: json['tally'] == null
          ? null
          : TimingsVotingTallyDto.fromJson(
              json['tally'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TimingsVotingDtoToJson(TimingsVotingDto instance) =>
    <String, dynamic>{
      'params': instance.params,
      'tally': instance.tally,
    };
