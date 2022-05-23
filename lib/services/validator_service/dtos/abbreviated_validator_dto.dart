import 'package:json_annotation/json_annotation.dart';

part 'abbreviated_validator_dto.g.dart';

@JsonSerializable()
class AbbreviatedValidatorDto {
  AbbreviatedValidatorDto({
    this.moniker,
    this.addressId,
    this.commission,
    this.imgUrl,
  });
  final String? moniker;
  final String? addressId;
  final String? commission;
  final String? imgUrl;

  // ignore: member-ordering
  factory AbbreviatedValidatorDto.fromJson(Map<String, dynamic> json) =>
      _$AbbreviatedValidatorDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AbbreviatedValidatorDtoToJson(this);
}
