// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bonded_tokens_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BondedTokensDto _$BondedTokensDtoFromJson(Map<String, dynamic> json) =>
    BondedTokensDto(
      count: json['count'] as int?,
      total: json['total'] as int?,
      denom: json['denom'] as String?,
    );

Map<String, dynamic> _$BondedTokensDtoToJson(BondedTokensDto instance) =>
    <String, dynamic>{
      'count': instance.count,
      'total': instance.total,
      'denom': instance.denom,
    };
