// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delegation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DelegationDto _$DelegationDtoFromJson(Map<String, dynamic> json) =>
    DelegationDto(
      delegatorAddr: json['delegatorAddr'] as String?,
      validatorSrcAddr: json['validatorSrcAddr'] as String?,
      validatorDstAddr: json['validatorDstAddr'] as String?,
      amount: json['amount'] == null
          ? null
          : BalanceDto.fromJson(json['amount'] as Map<String, dynamic>),
      initialBal: json['initialBal'] == null
          ? null
          : BalanceDto.fromJson(json['initialBal'] as Map<String, dynamic>),
      block: json['block'] as int?,
      endTime: json['endTime'] as int?,
    );

Map<String, dynamic> _$DelegationDtoToJson(DelegationDto instance) =>
    <String, dynamic>{
      'delegatorAddr': instance.delegatorAddr,
      'validatorSrcAddr': instance.validatorSrcAddr,
      'validatorDstAddr': instance.validatorDstAddr,
      'amount': instance.amount,
      'initialBal': instance.initialBal,
      'block': instance.block,
      'endTime': instance.endTime,
    };
