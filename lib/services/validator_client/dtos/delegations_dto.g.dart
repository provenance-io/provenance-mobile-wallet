// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delegations_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DelegationsDto _$DelegationsDtoFromJson(Map<String, dynamic> json) =>
    DelegationsDto(
      pages: json['pages'] as int?,
      total: json['total'] as int?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => DelegationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      rollupTotals: json['rollupTotals'] == null
          ? null
          : DelegationTotalsDto.fromJson(
              json['rollupTotals'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DelegationsDtoToJson(DelegationsDto instance) =>
    <String, dynamic>{
      'pages': instance.pages,
      'total': instance.total,
      'results': instance.results,
      'rollupTotals': instance.rollupTotals,
    };
