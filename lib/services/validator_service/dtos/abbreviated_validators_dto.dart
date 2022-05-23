import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/abbreviated_validator_dto.dart';

part 'abbreviated_validators_dto.g.dart';

@JsonSerializable()
class AbbreviatedValidatorsDto {
  AbbreviatedValidatorsDto({
    this.pages,
    this.total,
    this.results,
  });

  final int? pages;
  final int? total;
  final List<AbbreviatedValidatorDto>? results;

  // ignore: member-ordering
  factory AbbreviatedValidatorsDto.fromJson(Map<String, dynamic> json) =>
      _$AbbreviatedValidatorsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AbbreviatedValidatorsDtoToJson(this);
}
