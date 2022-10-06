// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_tx_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigTxDto _$MultiSigTxDtoFromJson(Map<String, dynamic> json) =>
    MultiSigTxDto(
      multiSigAddress: json['multiSigAddress'] as String,
      signerAddress: json['signerAddress'] as String,
      txUuid: json['txUuid'] as String,
      txBodyBytes: json['txBodyBytes'] as String,
      status: MultiSigStatus.fromJson(json['status'] as String),
      signatures: (json['signatures'] as List<dynamic>)
          .map(
              (e) => MultiSigTxSignatureDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MultiSigTxDtoToJson(MultiSigTxDto instance) =>
    <String, dynamic>{
      'multiSigAddress': instance.multiSigAddress,
      'signerAddress': instance.signerAddress,
      'txUuid': instance.txUuid,
      'txBodyBytes': instance.txBodyBytes,
      'status': instance.status,
      'signatures': instance.signatures,
    };
