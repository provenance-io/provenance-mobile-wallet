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
    );

Map<String, dynamic> _$DelegationTotalsDtoToJson(
        DelegationTotalsDto instance) =>
    <String, dynamic>{
      'bondedTotal': instance.bondedTotal,
    };
