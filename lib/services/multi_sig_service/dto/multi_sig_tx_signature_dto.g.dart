// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_tx_signature_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigTxSignatureDto _$MultiSigTxSignatureDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigTxSignatureDto(
      signerAddress: json['signerAddress'] as String,
      signatureHex: json['signatureBytes'] as String,
    );

Map<String, dynamic> _$MultiSigTxSignatureDtoToJson(
        MultiSigTxSignatureDto instance) =>
    <String, dynamic>{
      'signerAddress': instance.signerAddress,
      'signatureBytes': instance.signatureHex,
    };
