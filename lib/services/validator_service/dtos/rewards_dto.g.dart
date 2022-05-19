// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewards_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardsDto _$RewardsDtoFromJson(Map<String, dynamic> json) => RewardsDto(
      (json['reward'] as List<dynamic>)
          .map((e) => RewardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['validatorAddress'] as String?,
    );

Map<String, dynamic> _$RewardsDtoToJson(RewardsDto instance) =>
    <String, dynamic>{
      'reward': instance.reward,
      'validatorAddress': instance.validatorAddress,
    };
