// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetDto _$AssetDtoFromJson(Map<String, dynamic> json) => AssetDto(
      denom: json['denom'] as String?,
      amount: json['amount'] as String?,
      display: json['display'] as String?,
      description: json['description'] as String?,
      exponent: json['exponent'] as int?,
      displayAmount: json['displayAmount'] as String?,
      usdPrice: (json['usdPrice'] as num?)?.toDouble(),
      dailyHigh: (json['dailyHigh'] as num?)?.toDouble(),
      dailyLow: (json['dailyLow'] as num?)?.toDouble(),
      dailyVolume: (json['dailyVolume'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AssetDtoToJson(AssetDto instance) => <String, dynamic>{
      'denom': instance.denom,
      'amount': instance.amount,
      'display': instance.display,
      'description': instance.description,
      'exponent': instance.exponent,
      'displayAmount': instance.displayAmount,
      'usdPrice': instance.usdPrice,
      'dailyHigh': instance.dailyHigh,
      'dailyLow': instance.dailyLow,
      'dailyVolume': instance.dailyVolume,
    };
