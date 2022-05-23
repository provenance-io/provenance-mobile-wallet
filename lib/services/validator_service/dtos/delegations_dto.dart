import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/delegation_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/delegation_totals_dto.dart';

part 'delegations_dto.g.dart';

@JsonSerializable()
class DelegationsDto {
  DelegationsDto({
    this.pages,
    this.total,
    this.results,
    this.rollupTotals,
  });

  final int? pages;
  final int? total;
  final List<DelegationDto>? results;
  final DelegationTotalsDto? rollupTotals;

  // ignore: member-ordering
  factory DelegationsDto.fromJson(Map<String, dynamic> json) =>
      _$DelegationsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DelegationsDtoToJson(this);
}
