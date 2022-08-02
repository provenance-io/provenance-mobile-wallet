// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timings_deposit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimingsDepositDto _$TimingsDepositDtoFromJson(Map<String, dynamic> json) =>
    TimingsDepositDto(
      initial: json['initial'] as String?,
      current: json['current'] as String?,
      needed: json['needed'] as String?,
      denom: json['denom'] as String?,
    );

Map<String, dynamic> _$TimingsDepositDtoToJson(TimingsDepositDto instance) =>
    <String, dynamic>{
      'initial': instance.initial,
      'current': instance.current,
      'needed': instance.needed,
      'denom': instance.denom,
    };
