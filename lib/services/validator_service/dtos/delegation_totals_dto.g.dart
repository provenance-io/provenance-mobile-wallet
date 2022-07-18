// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delegation_totals_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DelegationTotalsDto _$DelegationTotalsDtoFromJson(Map<String, dynamic> json) =>
    DelegationTotalsDto(
      bondedTotal: json['bondedTotal'] == null
          ? null
          : BalanceDto.fromJson(json['bondedTotal'] as Map<String, dynamic>),
      redelegationTotal: json['redelegationTotal'] == null
          ? null
          : BalanceDto.fromJson(
              json['redelegationTotal'] as Map<String, dynamic>),
      unbondingTotal: json['unbondingTotal'] == null
          ? null
          : BalanceDto.fromJson(json['unbondingTotal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DelegationTotalsDtoToJson(
        DelegationTotalsDto instance) =>
    <String, dynamic>{
      'bondedTotal': instance.bondedTotal,
      'redelegationTotal': instance.redelegationTotal,
      'unbondingTotal': instance.unbondingTotal,
    };
