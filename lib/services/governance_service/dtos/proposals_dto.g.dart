// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposals_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposalssDto _$ProposalssDtoFromJson(Map<String, dynamic> json) =>
    ProposalssDto(
      pages: json['pages'] as int?,
      total: json['total'] as int?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => ProposalDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProposalssDtoToJson(ProposalssDto instance) =>
    <String, dynamic>{
      'pages': instance.pages,
      'total': instance.total,
      'results': instance.results,
    };
