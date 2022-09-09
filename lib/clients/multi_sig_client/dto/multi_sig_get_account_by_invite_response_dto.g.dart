// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_get_account_by_invite_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigGetAccountByInviteResponseDto
    _$MultiSigGetAccountByInviteResponseDtoFromJson(
            Map<String, dynamic> json) =>
        MultiSigGetAccountByInviteResponseDto(
          name: json['name'] as String,
          walletUuid: json['walletUuid'] as String,
          threshold: json['threshold'] as int,
          status: json['status'] as String,
          chainId: json['chainId'] as String,
          signers: (json['signers'] as List<dynamic>)
              .map((e) => MultiSigSignerDto.fromJson(e as Map<String, dynamic>))
              .toList(),
          publicKey: json['publicKey'] as String?,
          address: json['address'] as String?,
        );

Map<String, dynamic> _$MultiSigGetAccountByInviteResponseDtoToJson(
        MultiSigGetAccountByInviteResponseDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'walletUuid': instance.walletUuid,
      'threshold': instance.threshold,
      'status': instance.status,
      'chainId': instance.chainId,
      'signers': instance.signers,
      'publicKey': instance.publicKey,
      'address': instance.address,
    };
