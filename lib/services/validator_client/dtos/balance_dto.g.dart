// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BalanceDto _$BalanceDtoFromJson(Map<String, dynamic> json) => BalanceDto(
      amount: json['amount'] as String?,
      denom: json['denom'] as String?,
    );

Map<String, dynamic> _$BalanceDtoToJson(BalanceDto instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'denom': instance.denom,
    };
