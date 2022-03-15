// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceDto _$PriceDtoFromJson(Map<String, dynamic> json) => PriceDto(
      markerDenom: json['markerDenom'] as String?,
      usdPrice: (json['usdPrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PriceDtoToJson(PriceDto instance) => <String, dynamic>{
      'markerDenom': instance.markerDenom,
      'usdPrice': instance.usdPrice,
    };
