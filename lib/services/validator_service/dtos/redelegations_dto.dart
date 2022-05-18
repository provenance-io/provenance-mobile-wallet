import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/delegation_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/redelegation_totals_dto.dart';

part 'redelegations_dto.g.dart';

@JsonSerializable()
class RedelegationsDto {
  RedelegationsDto({
    this.pages,
    this.total,
    this.results,
    this.rollupTotals,
  });

  final int? pages;
  final int? total;
  final List<DelegationDto>? results;
  final RedelegationTotalsDto? rollupTotals;

  // ignore: member-ordering
  factory RedelegationsDto.fromJson(Map<String, dynamic> json) =>
      _$RedelegationsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RedelegationsDtoToJson(this);
}
