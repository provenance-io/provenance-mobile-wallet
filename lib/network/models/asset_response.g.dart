// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetResponse _$AssetResponseFromJson(Map<String, dynamic> json) =>
    AssetResponse(
      denom: json['denom'] as String?,
      amount: json['amount'] as String?,
      display: json['display'] as String?,
      description: json['description'] as String?,
      exponent: json['exponent'] as int?,
      displayAmount: json['displayAmount'] as String?,
    );

Map<String, dynamic> _$AssetResponseToJson(AssetResponse instance) =>
    <String, dynamic>{
      'denom': instance.denom,
      'amount': instance.amount,
      'display': instance.display,
      'description': instance.description,
      'exponent': instance.exponent,
      'displayAmount': instance.displayAmount,
    };
