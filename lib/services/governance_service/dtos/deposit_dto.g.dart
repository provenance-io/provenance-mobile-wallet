// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deposit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepositDto _$DepositDtoFromJson(Map<String, dynamic> json) => DepositDto(
      voter: json['voter'] == null
          ? null
          : ProposerDto.fromJson(json['voter'] as Map<String, dynamic>),
      type: json['type'] as String?,
      amount: json['amount'] == null
          ? null
          : BalanceDto.fromJson(json['amount'] as Map<String, dynamic>),
      blockHeight: json['blockHeight'] as int?,
      txHash: json['txHash'] as String?,
      txTimestamp: json['txTimestamp'] == null
          ? null
          : DateTime.parse(json['txTimestamp'] as String),
    );

Map<String, dynamic> _$DepositDtoToJson(DepositDto instance) =>
    <String, dynamic>{
      'voter': instance.voter,
      'type': instance.type,
      'amount': instance.amount,
      'blockHeight': instance.blockHeight,
      'txHash': instance.txHash,
      'txTimestamp': instance.txTimestamp?.toIso8601String(),
    };
