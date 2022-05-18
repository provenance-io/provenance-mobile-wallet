// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redelegations_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedelegationsDto _$RedelegationsDtoFromJson(Map<String, dynamic> json) =>
    RedelegationsDto(
      pages: json['pages'] as int?,
      total: json['total'] as int?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => DelegationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      rollupTotals: json['rollupTotals'] == null
          ? null
          : RedelegationTotalsDto.fromJson(
              json['rollupTotals'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RedelegationsDtoToJson(RedelegationsDto instance) =>
    <String, dynamic>{
      'pages': instance.pages,
      'total': instance.total,
      'results': instance.results,
      'rollupTotals': instance.rollupTotals,
    };
