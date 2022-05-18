// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'undelegation_totals_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UndelegationTotalsDto _$UndelegationTotalsDtoFromJson(
        Map<String, dynamic> json) =>
    UndelegationTotalsDto(
      redelegationTotal: json['redelegationTotal'] == null
          ? null
          : BalanceDto.fromJson(
              json['redelegationTotal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UndelegationTotalsDtoToJson(
        UndelegationTotalsDto instance) =>
    <String, dynamic>{
      'redelegationTotal': instance.redelegationTotal,
    };
