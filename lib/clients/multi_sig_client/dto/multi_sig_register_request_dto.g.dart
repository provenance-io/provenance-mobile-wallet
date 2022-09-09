// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_register_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigRegisterRequestDto _$MultiSigRegisterRequestDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigRegisterRequestDto(
      inviteUuid: json['inviteUuid'] as String,
      publicKey: json['publicKey'] as String,
      address: json['address'] as String,
    );

Map<String, dynamic> _$MultiSigRegisterRequestDtoToJson(
        MultiSigRegisterRequestDto instance) =>
    <String, dynamic>{
      'inviteUuid': instance.inviteUuid,
      'publicKey': instance.publicKey,
      'address': instance.address,
    };
