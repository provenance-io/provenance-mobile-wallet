// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_register_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigRegisterResponseDto _$MultiSigRegisterResponseDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigRegisterResponseDto(
      address: json['address'] as String,
      inviteUuid: json['inviteUuid'] as String,
      publicKey: json['publicKey'] as String,
      redeemDate: json['redeemDate'] as String,
      signerOrder: json['signerOrder'] as int,
      signerUuid: json['signerUuid'] as String,
    );

Map<String, dynamic> _$MultiSigRegisterResponseDtoToJson(
        MultiSigRegisterResponseDto instance) =>
    <String, dynamic>{
      'address': instance.address,
      'inviteUuid': instance.inviteUuid,
      'publicKey': instance.publicKey,
      'redeemDate': instance.redeemDate,
      'signerOrder': instance.signerOrder,
      'signerUuid': instance.signerUuid,
    };
