// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stat_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatDto _$StatDtoFromJson(Map<String, dynamic> json) => StatDto(
      marketCap: json['marketCap'] as double?,
      validators: json['validators'] as int?,
      transactions: json['transactions'] as int?,
      averageBlockTime: json['averageBlockTime'] as double?,
    );

Map<String, dynamic> _$StatDtoToJson(StatDto instance) => <String, dynamic>{
      'marketCap': instance.marketCap,
      'validators': instance.validators,
      'transactions': instance.transactions,
      'averageBlockTime': instance.averageBlockTime,
    };
