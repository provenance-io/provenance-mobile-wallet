// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gas_fee_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GasFeeDto _$GasFeeDtoFromJson(Map<String, dynamic> json) => GasFeeDto(
      gasPriceDenom: json['gasPriceDenom'] as String?,
      gasPrice: json['gasPrice'] as int?,
    );

Map<String, dynamic> _$GasFeeDtoToJson(GasFeeDto instance) => <String, dynamic>{
      'gasPriceDenom': instance.gasPriceDenom,
      'gasPrice': instance.gasPrice,
    };
