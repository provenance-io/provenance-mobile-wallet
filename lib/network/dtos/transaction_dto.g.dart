// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionDto _$TransactionDtoFromJson(Map<String, dynamic> json) =>
    TransactionDto(
      address: json['address'] as String?,
      feeAmount: json['feeAmount'] as String?,
      id: json['id'] as String?,
      signer: json['signer'] as String?,
      status: json['status'] as String?,
      time: json['time'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$TransactionDtoToJson(TransactionDto instance) =>
    <String, dynamic>{
      'address': instance.address,
      'feeAmount': instance.feeAmount,
      'id': instance.id,
      'signer': instance.signer,
      'status': instance.status,
      'time': instance.time,
      'type': instance.type,
    };
