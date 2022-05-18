// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redelegation_totals_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedelegationTotalsDto _$RedelegationTotalsDtoFromJson(
        Map<String, dynamic> json) =>
    RedelegationTotalsDto(
      redelegationTotal: json['redelegationTotal'] == null
          ? null
          : BalanceDto.fromJson(
              json['redelegationTotal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RedelegationTotalsDtoToJson(
        RedelegationTotalsDto instance) =>
    <String, dynamic>{
      'redelegationTotal': instance.redelegationTotal,
    };
