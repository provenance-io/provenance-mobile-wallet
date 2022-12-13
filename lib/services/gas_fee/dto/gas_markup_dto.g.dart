// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gas_markup_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GasPriceDto _$GasPriceDtoFromJson(Map<String, dynamic> json) => GasPriceDto(
      denom: json['gasPriceDenom'] as String?,
      amount: (json['gasPrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$GasPriceDtoToJson(GasPriceDto instance) =>
    <String, dynamic>{
      'gasPriceDenom': instance.denom,
      'gasPrice': instance.amount,
    };
