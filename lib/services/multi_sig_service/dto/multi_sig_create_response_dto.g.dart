// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_sig_create_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiSigCreateResponseDto _$MultiSigCreateResponseDtoFromJson(
        Map<String, dynamic> json) =>
    MultiSigCreateResponseDto(
      name: json['name'] as String,
      walletUuid: json['walletUuid'] as String,
      inviteLinks: (json['inviteLinks'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MultiSigCreateResponseDtoToJson(
        MultiSigCreateResponseDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'walletUuid': instance.walletUuid,
      'inviteLinks': instance.inviteLinks,
    };
