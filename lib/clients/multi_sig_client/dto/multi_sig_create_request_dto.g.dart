// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_create_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigCreateRequestDto _$MultiSigCreateRequestDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigCreateRequestDto(
      name: json['name'] as String,
      publicKey: json['publicKey'] as String,
      address: json['address'] as String,
      numOfAdditionalSigners: json['numOfAdditionalSigners'] as int,
      threshold: json['threshold'] as int,
      chainId: json['chainId'] as String,
    );

Map<String, dynamic> _$MultiSigCreateRequestDtoToJson(
        MultiSigCreateRequestDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'publicKey': instance.publicKey,
      'address': instance.address,
      'numOfAdditionalSigners': instance.numOfAdditionalSigners,
      'threshold': instance.threshold,
      'chainId': instance.chainId,
    };
