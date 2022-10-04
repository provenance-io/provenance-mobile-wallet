// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardDto _$RewardDtoFromJson(Map<String, dynamic> json) => RewardDto(
      json['amount'] as String?,
      json['denom'] as String?,
      json['pricePerToken'] == null
          ? null
          : BalanceDto.fromJson(json['pricePerToken'] as Map<String, dynamic>),
      json['totalBalancePrice'] == null
          ? null
          : BalanceDto.fromJson(
              json['totalBalancePrice'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RewardDtoToJson(RewardDto instance) => <String, dynamic>{
      'amount': instance.amount,
      'denom': instance.denom,
      'pricePerToken': instance.pricePerToken,
      'totalBalancePrice': instance.totalBalancePrice,
    };
