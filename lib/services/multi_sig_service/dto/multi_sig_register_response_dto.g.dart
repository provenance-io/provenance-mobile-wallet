// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_register_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigRegisterResponseDto _$MultiSigRegisterResponseDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigRegisterResponseDto(
      name: json['name'] as String,
      walletUuid: json['walletUuid'] as String,
      inviteLinks: (json['inviteLinks'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MultiSigRegisterResponseDtoToJson(
        MultiSigRegisterResponseDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'walletUuid': instance.walletUuid,
      'inviteLinks': instance.inviteLinks,
    };
