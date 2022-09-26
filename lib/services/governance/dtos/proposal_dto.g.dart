// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposalDto _$ProposalDtoFromJson(Map<String, dynamic> json) => ProposalDto(
      header: json['header'] == null
          ? null
          : HeaderDto.fromJson(json['header'] as Map<String, dynamic>),
      timings: json['timings'] == null
          ? null
          : TimingsDto.fromJson(json['timings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProposalDtoToJson(ProposalDto instance) =>
    <String, dynamic>{
      'header': instance.header,
      'timings': instance.timings,
    };
