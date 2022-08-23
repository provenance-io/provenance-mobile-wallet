// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_created_tx_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigCreatedTxDto _$MultiSigCreatedTxDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigCreatedTxDto(
      multiSigAddress: json['multiSigAddress'] as String,
      txUuid: json['txUuid'] as String,
      txBodyBytes: json['txBodyBytes'] as String,
      status: json['status'] as String,
      signatures: (json['signatures'] as List<dynamic>?)
          ?.map(
              (e) => MultiSigTxSignatureDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MultiSigCreatedTxDtoToJson(
        MultiSigCreatedTxDto instance) =>
    <String, dynamic>{
      'multiSigAddress': instance.multiSigAddress,
      'txUuid': instance.txUuid,
      'txBodyBytes': instance.txBodyBytes,
      'status': instance.status,
      'signatures': instance.signatures,
    };
