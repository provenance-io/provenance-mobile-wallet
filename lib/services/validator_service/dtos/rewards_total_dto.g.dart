// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewards_total_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardsTotalDto _$RewardsTotalDtoFromJson(Map<String, dynamic> json) =>
    RewardsTotalDto(
      (json['rewards'] as List<dynamic>)
          .map((e) => RewardsDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['total'] as List<dynamic>)
          .map((e) => RewardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RewardsTotalDtoToJson(RewardsTotalDto instance) =>
    <String, dynamic>{
      'rewards': instance.rewards,
      'total': instance.total,
    };
