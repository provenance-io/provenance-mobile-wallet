// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_update_tx_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigUpdateTxRequestDto _$MultiSigUpdateTxRequestDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigUpdateTxRequestDto(
      txUuid: json['txUuid'] as String,
      txHash: json['txHash'] as String,
    );

Map<String, dynamic> _$MultiSigUpdateTxRequestDtoToJson(
        MultiSigUpdateTxRequestDto instance) =>
    <String, dynamic>{
      'txUuid': instance.txUuid,
      'txHash': instance.txHash,
    };
