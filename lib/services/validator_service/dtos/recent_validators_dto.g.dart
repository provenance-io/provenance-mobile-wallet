// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_validators_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecentValidatorsDto _$RecentValidatorsDtoFromJson(Map<String, dynamic> json) =>
    RecentValidatorsDto(
      pages: json['pages'] as int?,
      totalCount: json['totalCount'] as int?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => RecentValidatorDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecentValidatorsDtoToJson(
        RecentValidatorsDto instance) =>
    <String, dynamic>{
      'pages': instance.pages,
      'totalCount': instance.totalCount,
      'results': instance.results,
    };
