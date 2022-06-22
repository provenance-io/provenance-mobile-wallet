// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_finalize_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigFinalizeRequestDto _$MultiSigFinalizeRequestDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigFinalizeRequestDto(
      walletUuid: json['walletUuid'] as String,
      publicKey: json['publicKey'] as String,
    );

Map<String, dynamic> _$MultiSigFinalizeRequestDtoToJson(
        MultiSigFinalizeRequestDto instance) =>
    <String, dynamic>{
      'walletUuid': instance.walletUuid,
      'publicKey': instance.publicKey,
    };
