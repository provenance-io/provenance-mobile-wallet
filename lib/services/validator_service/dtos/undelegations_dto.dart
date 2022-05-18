import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/delegation_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/undelegation_totals_dto.dart';

part 'undelegations_dto.g.dart';

@JsonSerializable()
class UndelegationsDto {
  UndelegationsDto({
    this.pages,
    this.total,
    this.results,
    this.rollupTotals,
  });

  final int? pages;
  final int? total;
  final List<DelegationDto>? results;
  final UndelegationTotalsDto? rollupTotals;

  // ignore: member-ordering
  factory UndelegationsDto.fromJson(Map<String, dynamic> json) =>
      _$UndelegationsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UndelegationsDtoToJson(this);
}
