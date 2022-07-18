// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commission_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommissionDto _$CommissionDtoFromJson(Map<String, dynamic> json) =>
    CommissionDto(
      bondedTokens: json['bondedTokens'] == null
          ? null
          : BondedTokensDto.fromJson(
              json['bondedTokens'] as Map<String, dynamic>),
      selfBonded: json['selfBonded'] == null
          ? null
          : BondedTokensDto.fromJson(
              json['selfBonded'] as Map<String, dynamic>),
      delegatorBonded: json['delegatorBonded'] == null
          ? null
          : BondedTokensDto.fromJson(
              json['delegatorBonded'] as Map<String, dynamic>),
      delegatorCount: json['delegatorCount'] as int?,
      totalShares: json['totalShares'] as String?,
      commissionRewards: json['commissionRewards'] == null
          ? null
          : BalanceDto.fromJson(
              json['commissionRewards'] as Map<String, dynamic>),
      commissionRate: json['commissionRate'] == null
          ? null
          : CommissionRateDto.fromJson(
              json['commissionRate'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommissionDtoToJson(CommissionDto instance) =>
    <String, dynamic>{
      'bondedTokens': instance.bondedTokens,
      'selfBonded': instance.selfBonded,
      'delegatorBonded': instance.delegatorBonded,
      'delegatorCount': instance.delegatorCount,
      'totalShares': instance.totalShares,
      'commissionRewards': instance.commissionRewards,
      'commissionRate': instance.commissionRate,
    };
