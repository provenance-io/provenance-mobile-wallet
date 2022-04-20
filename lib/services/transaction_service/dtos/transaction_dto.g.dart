// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionDto _$TransactionDtoFromJson(Map<String, dynamic> json) =>
    TransactionDto(
      block: json['block'] as int?,
      feeAmount: json['feeAmount'] as String?,
      hash: json['hash'] as String?,
      signer: json['signer'] as String?,
      status: json['status'] as String?,
      time:
          json['time'] == null ? null : DateTime.parse(json['time'] as String),
      type: json['type'] as String?,
      denom: json['denom'] as String?,
    );

Map<String, dynamic> _$TransactionDtoToJson(TransactionDto instance) =>
    <String, dynamic>{
      'block': instance.block,
      'feeAmount': instance.feeAmount,
      'hash': instance.hash,
      'signer': instance.signer,
      'status': instance.status,
      'time': instance.time?.toIso8601String(),
      'type': instance.type,
      'denom': instance.denom,
    };
