// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_signer_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigSignerDto _$MultiSigSignerDtoFromJson(Map<String, dynamic> json) =>
    MultiSigSignerDto(
      signerUuid: json['signerUuid'] as String,
      inviteUuid: json['inviteUuid'] as String,
      originalSigner: json['originalSigner'] as bool,
      publicKey: json['publicKey'] as String?,
      address: json['address'] as String?,
      redeemDate: json['redeemDate'] as String?,
    );

Map<String, dynamic> _$MultiSigSignerDtoToJson(MultiSigSignerDto instance) =>
    <String, dynamic>{
      'signerUuid': instance.signerUuid,
      'inviteUuid': instance.inviteUuid,
      'originalSigner': instance.originalSigner,
      'publicKey': instance.publicKey,
      'address': instance.address,
      'redeemDate': instance.redeemDate,
    };
