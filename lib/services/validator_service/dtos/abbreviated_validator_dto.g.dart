// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'abbreviated_validator_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbbreviatedValidatorDto _$AbbreviatedValidatorDtoFromJson(
        Map<String, dynamic> json) =>
    AbbreviatedValidatorDto(
      moniker: json['moniker'] as String?,
      addressId: json['addressId'] as String?,
      commission: json['commission'] as String?,
      imgUrl: json['imgUrl'] as String?,
    );

Map<String, dynamic> _$AbbreviatedValidatorDtoToJson(
        AbbreviatedValidatorDto instance) =>
    <String, dynamic>{
      'moniker': instance.moniker,
      'addressId': instance.addressId,
      'commission': instance.commission,
      'imgUrl': instance.imgUrl,
    };
