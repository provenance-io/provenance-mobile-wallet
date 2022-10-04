// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'header_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeaderDto _$HeaderDtoFromJson(Map<String, dynamic> json) => HeaderDto(
      proposalId: json['proposalId'] as int?,
      status: json['status'] as String?,
      proposer: json['proposer'] == null
          ? null
          : ProposerDto.fromJson(json['proposer'] as Map<String, dynamic>),
      type: json['type'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$HeaderDtoToJson(HeaderDto instance) => <String, dynamic>{
      'proposalId': instance.proposalId,
      'status': instance.status,
      'proposer': instance.proposer,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
    };
