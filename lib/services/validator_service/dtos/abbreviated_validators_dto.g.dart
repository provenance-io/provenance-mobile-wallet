// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'abbreviated_validators_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbbreviatedValidatorsDto _$AbbreviatedValidatorsDtoFromJson(
        Map<String, dynamic> json) =>
    AbbreviatedValidatorsDto(
      pages: json['pages'] as int?,
      total: json['total'] as int?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) =>
              AbbreviatedValidatorDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AbbreviatedValidatorsDtoToJson(
        AbbreviatedValidatorsDto instance) =>
    <String, dynamic>{
      'pages': instance.pages,
      'total': instance.total,
      'results': instance.results,
    };
