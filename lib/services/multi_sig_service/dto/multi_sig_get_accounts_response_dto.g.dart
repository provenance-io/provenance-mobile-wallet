// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_get_accounts_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigGetAccountsResponseDto _$MultiSigGetAccountsResponseDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigGetAccountsResponseDto(
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

Map<String, dynamic> _$MultiSigGetAccountsResponseDtoToJson(
        MultiSigGetAccountsResponseDto instance) =>
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
