// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_create_tx_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigCreateTxRequestDto _$MultiSigCreateTxRequestDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigCreateTxRequestDto(
      multiSigAddress: json['walletAddress'] as String,
      signerAddress: json['accountAddress'] as String,
      txBodyBytes: json['txBodyBytes'] as String,
    );

Map<String, dynamic> _$MultiSigCreateTxRequestDtoToJson(
        MultiSigCreateTxRequestDto instance) =>
    <String, dynamic>{
      'walletAddress': instance.multiSigAddress,
      'accountAddress': instance.signerAddress,
      'txBodyBytes': instance.txBodyBytes,
    };
