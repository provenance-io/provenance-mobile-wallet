// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'undelegations_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UndelegationsDto _$UndelegationsDtoFromJson(Map<String, dynamic> json) =>
    UndelegationsDto(
      pages: json['pages'] as int?,
      total: json['total'] as int?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => DelegationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      rollupTotals: json['rollupTotals'] == null
          ? null
          : UndelegationTotalsDto.fromJson(
              json['rollupTotals'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UndelegationsDtoToJson(UndelegationsDto instance) =>
    <String, dynamic>{
      'pages': instance.pages,
      'total': instance.total,
      'results': instance.results,
      'rollupTotals': instance.rollupTotals,
    };
