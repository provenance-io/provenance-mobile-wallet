// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_register_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigRegisterRequestDto _$MultiSigRegisterRequestDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigRegisterRequestDto(
      name: json['name'] as String,
      publicKey: json['publicKey'] as String,
      address: json['address'] as String,
      numOfAdditionalSigners: json['numOfAdditionalSigners'] as int,
      threshold: json['threshold'] as int,
      chainId: json['chainId'] as String,
    );

Map<String, dynamic> _$MultiSigRegisterRequestDtoToJson(
        MultiSigRegisterRequestDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'publicKey': instance.publicKey,
      'address': instance.address,
      'numOfAdditionalSigners': instance.numOfAdditionalSigners,
      'threshold': instance.threshold,
      'chainId': instance.chainId,
    };
