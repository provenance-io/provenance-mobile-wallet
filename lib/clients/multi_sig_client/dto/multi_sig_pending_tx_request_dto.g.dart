// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_pending_tx_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigPendingTxRequestDto _$MultiSigPendingTxRequestDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigPendingTxRequestDto(
      addresses:
          (json['addresses'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MultiSigPendingTxRequestDtoToJson(
        MultiSigPendingTxRequestDto instance) =>
    <String, dynamic>{
      'addresses': instance.addresses,
    };
