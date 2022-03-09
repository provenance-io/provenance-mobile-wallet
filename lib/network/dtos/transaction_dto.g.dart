// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionDto _$TransactionDtoFromJson(Map<String, dynamic> json) =>
    TransactionDto(
      address: json['recipientAddress'] as String?,
      feeAmount: json['txFee'] as int?,
      id: json['hash'] as String?,
      signer: json['senderAddress'] as String?,
      status: json['status'] as String?,
      time: json['timestamp'] as String?,
    );

Map<String, dynamic> _$TransactionDtoToJson(TransactionDto instance) =>
    <String, dynamic>{
      'recipientAddress': instance.address,
      'txFee': instance.feeAmount,
      'hash': instance.id,
      'senderAddress': instance.signer,
      'status': instance.status,
      'timestamp': instance.time,
    };
