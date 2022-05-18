import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/recent_validator_dto.dart';

part 'recent_validators_dto.g.dart';

@JsonSerializable()
class RecentValidatorsDto {
  RecentValidatorsDto({
    this.pages,
    this.totalCount,
    this.results,
  });

  final int? pages;
  final int? totalCount;
  final List<RecentValidatorDto>? results;

  // ignore: member-ordering
  factory RecentValidatorsDto.fromJson(Map<String, dynamic> json) =>
      _$RecentValidatorsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RecentValidatorsDtoToJson(this);
}
