// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_sign_tx_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigSignTxRequest _$MultiSigSignTxRequestFromJson(
        Map<String, dynamic> json) =>
    MultiSigSignTxRequest(
      address: json['address'] as String,
      txUuid: json['txUuid'] as String,
      signatureBytes: json['signatureBytes'] as String?,
      declineTx: json['declineTx'] as bool?,
    );

Map<String, dynamic> _$MultiSigSignTxRequestToJson(
        MultiSigSignTxRequest instance) =>
    <String, dynamic>{
      'address': instance.address,
      'txUuid': instance.txUuid,
      'signatureBytes': instance.signatureBytes,
      'declineTx': instance.declineTx,
    };
