// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detailed_validator_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetailedValidatorDto _$DetailedValidatorDtoFromJson(
        Map<String, dynamic> json) =>
    DetailedValidatorDto(
      blockCount: json['blockCount'] == null
          ? null
          : BlockCountDto.fromJson(json['blockCount'] as Map<String, dynamic>),
      bondHeight: json['bondHeight'] as int?,
      consensusPubKey: json['consensusPubKey'] as String?,
      description: json['description'] as String?,
      identity: json['identity'] as String?,
      imgUrl: json['imgUrl'] as String?,
      jailedUntil: json['jailedUntil'] as String?,
      moniker: json['moniker'] as String?,
      operatorAddress: json['operatorAddress'] as String?,
      ownerAddress: json['ownerAddress'] as String?,
      siteUrl: json['siteUrl'] as String?,
      status: json['status'] as String?,
      unbondingHeight: json['unbondingHeight'] as int?,
      uptime: (json['uptime'] as num?)?.toDouble(),
      votingPower: json['votingPower'] == null
          ? null
          : VotingPowerDto.fromJson(
              json['votingPower'] as Map<String, dynamic>),
      withdrawalAddress: json['withdrawalAddress'] as String?,
    );

Map<String, dynamic> _$DetailedValidatorDtoToJson(
        DetailedValidatorDto instance) =>
    <String, dynamic>{
      'blockCount': instance.blockCount,
      'bondHeight': instance.bondHeight,
      'consensusPubKey': instance.consensusPubKey,
      'description': instance.description,
      'identity': instance.identity,
      'imgUrl': instance.imgUrl,
      'jailedUntil': instance.jailedUntil,
      'moniker': instance.moniker,
      'operatorAddress': instance.operatorAddress,
      'ownerAddress': instance.ownerAddress,
      'siteUrl': instance.siteUrl,
      'status': instance.status,
      'unbondingHeight': instance.unbondingHeight,
      'uptime': instance.uptime,
      'votingPower': instance.votingPower,
      'withdrawalAddress': instance.withdrawalAddress,
    };
