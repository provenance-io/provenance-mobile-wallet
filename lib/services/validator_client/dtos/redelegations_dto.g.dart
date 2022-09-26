// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redelegations_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedelegationsDto _$RedelegationsDtoFromJson(Map<String, dynamic> json) =>
    RedelegationsDto(
      records: (json['records'] as List<dynamic>?)
          ?.map((e) => DelegationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      rollupTotals: json['rollupTotals'] == null
          ? null
          : DelegationDto.fromJson(
              json['rollupTotals'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RedelegationsDtoToJson(RedelegationsDto instance) =>
    <String, dynamic>{
      'records': instance.records,
      'rollupTotals': instance.rollupTotals,
    };
