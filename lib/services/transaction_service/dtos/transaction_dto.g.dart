// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionDto _$TransactionDtoFromJson(Map<String, dynamic> json) =>
    TransactionDto(
      amount: json['amount'] as int?,
      block: json['block'] as int?,
      denom: json['denom'] as String?,
      hash: json['hash'] as String?,
      recipientAddress: json['recipientAddress'] as String?,
      senderAddress: json['senderAddress'] as String?,
      status: json['status'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      txFee: json['txFee'] as int?,
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      exponent: json['exponent'] as int?,
    );

Map<String, dynamic> _$TransactionDtoToJson(TransactionDto instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'block': instance.block,
      'denom': instance.denom,
      'hash': instance.hash,
      'recipientAddress': instance.recipientAddress,
      'senderAddress': instance.senderAddress,
      'status': instance.status,
      'timestamp': instance.timestamp?.toIso8601String(),
      'txFee': instance.txFee,
      'pricePerUnit': instance.pricePerUnit,
      'totalPrice': instance.totalPrice,
      'exponent': instance.exponent,
    };
