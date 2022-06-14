// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'height_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeightDto _$HeightDtoFromJson(Map<String, dynamic> json) => HeightDto(
      height: json['height'] as int?,
      hash: json['hash'] as String?,
      time:
          json['time'] == null ? null : DateTime.parse(json['time'] as String),
      proposerAddress: json['proposerAddress'] as String?,
      moniker: json['moniker'] as String?,
      icon: json['icon'] as String?,
      votingPower: json['votingPower'] == null
          ? null
          : VotingPowerDto.fromJson(
              json['votingPower'] as Map<String, dynamic>),
      validatorCount: json['validatorCount'] == null
          ? null
          : VotingPowerDto.fromJson(
              json['validatorCount'] as Map<String, dynamic>),
      txNum: json['txNum'] as int?,
    );

Map<String, dynamic> _$HeightDtoToJson(HeightDto instance) => <String, dynamic>{
      'height': instance.height,
      'hash': instance.hash,
      'time': instance.time?.toIso8601String(),
      'proposerAddress': instance.proposerAddress,
      'moniker': instance.moniker,
      'icon': instance.icon,
      'votingPower': instance.votingPower,
      'validatorCount': instance.validatorCount,
      'txNum': instance.txNum,
    };
