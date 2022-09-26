// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_validator_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecentValidatorDto _$RecentValidatorDtoFromJson(Map<String, dynamic> json) =>
    RecentValidatorDto(
      moniker: json['moniker'] as String?,
      addressId: json['addressId'] as String?,
      consensusAddress: json['consensusAddress'] as String?,
      proposerPriority: json['proposerPriority'] as int?,
      votingPower: json['votingPower'] == null
          ? null
          : VotingPowerDto.fromJson(
              json['votingPower'] as Map<String, dynamic>),
      commission: json['commission'] as String?,
      bondedTokens: json['bondedTokens'] == null
          ? null
          : BondedTokensDto.fromJson(
              json['bondedTokens'] as Map<String, dynamic>),
      delegators: json['delegators'] as int?,
      status: json['status'] as String?,
      imgUrl: json['imgUrl'] as String?,
      hr24Change: json['hr24Change'] as String?,
      uptime: (json['uptime'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RecentValidatorDtoToJson(RecentValidatorDto instance) =>
    <String, dynamic>{
      'moniker': instance.moniker,
      'addressId': instance.addressId,
      'consensusAddress': instance.consensusAddress,
      'proposerPriority': instance.proposerPriority,
      'votingPower': instance.votingPower,
      'commission': instance.commission,
      'bondedTokens': instance.bondedTokens,
      'delegators': instance.delegators,
      'status': instance.status,
      'imgUrl': instance.imgUrl,
      'hr24Change': instance.hr24Change,
      'uptime': instance.uptime,
    };
