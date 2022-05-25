// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commission_rate_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommissionRateDto _$CommissionRateDtoFromJson(Map<String, dynamic> json) =>
    CommissionRateDto(
      rate: json['rate'] as String?,
      maxRate: json['maxRate'] as String?,
      maxChangeRate: json['maxChangeRate'] as String?,
    );

Map<String, dynamic> _$CommissionRateDtoToJson(CommissionRateDto instance) =>
    <String, dynamic>{
      'rate': instance.rate,
      'maxRate': instance.maxRate,
      'maxChangeRate': instance.maxChangeRate,
    };
