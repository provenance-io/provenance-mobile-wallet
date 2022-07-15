// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_signer_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigSignerDto _$MultiSigSignerDtoFromJson(Map<String, dynamic> json) =>
    MultiSigSignerDto(
      inviteUuid: json['inviteUuid'] as String,
      signerUuid: json['signerUuid'] as String,
      signerOrder: json['signerOrder'] as int,
      address: json['address'] as String?,
      publicKey: json['publicKey'] as String?,
      redeemDate: json['redeemDate'] as String?,
    );

Map<String, dynamic> _$MultiSigSignerDtoToJson(MultiSigSignerDto instance) =>
    <String, dynamic>{
      'inviteUuid': instance.inviteUuid,
      'signerUuid': instance.signerUuid,
      'signerOrder': instance.signerOrder,
      'address': instance.address,
      'publicKey': instance.publicKey,
      'redeemDate': instance.redeemDate,
    };
