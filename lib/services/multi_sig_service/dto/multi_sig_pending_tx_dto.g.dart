// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_pending_tx_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigPendingTxDto _$MultiSigPendingTxDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigPendingTxDto(
      multiSigAddress: json['multiSigAddress'] as String,
      txUuid: json['txUuid'] as String,
      txBodyBytes: json['txBodyBytes'] as String,
    );

Map<String, dynamic> _$MultiSigPendingTxDtoToJson(
        MultiSigPendingTxDto instance) =>
    <String, dynamic>{
      'multiSigAddress': instance.multiSigAddress,
      'txUuid': instance.txUuid,
      'txBodyBytes': instance.txBodyBytes,
    };
