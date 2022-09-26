// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposer_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposerDto _$ProposerDtoFromJson(Map<String, dynamic> json) => ProposerDto(
      address: json['address'] as String?,
      validatorAddr: json['validatorAddr'] as String?,
      moniker: json['moniker'] as String?,
    );

Map<String, dynamic> _$ProposerDtoToJson(ProposerDto instance) =>
    <String, dynamic>{
      'address': instance.address,
      'validatorAddr': instance.validatorAddr,
      'moniker': instance.moniker,
    };
