// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_create_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigCreateResponseDto _$MultiSigCreateResponseDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigCreateResponseDto(
      chainId: json['chainId'] as String,
      name: json['name'] as String,
      signers: (json['signers'] as List<dynamic>)
          .map((e) => MultiSigSignerDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      threshold: json['threshold'] as int,
      walletUuid: json['walletUuid'] as String,
    );

Map<String, dynamic> _$MultiSigCreateResponseDtoToJson(
        MultiSigCreateResponseDto instance) =>
    <String, dynamic>{
      'chainId': instance.chainId,
      'name': instance.name,
      'signers': instance.signers,
      'status': instance.status,
      'threshold': instance.threshold,
      'walletUuid': instance.walletUuid,
    };
