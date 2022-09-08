// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_created_tx_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigCreatedTxRequestDto _$MultiSigCreatedTxRequestDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigCreatedTxRequestDto(
      addresses:
          (json['addresses'] as List<dynamic>).map((e) => e as String).toList(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$MultiSigCreatedTxRequestDtoToJson(
        MultiSigCreatedTxRequestDto instance) =>
    <String, dynamic>{
      'addresses': instance.addresses,
      'status': instance.status,
    };
