import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/balance_dto.dart';

part 'delegation_totals_dto.g.dart';

@JsonSerializable()
class DelegationTotalsDto {
  DelegationTotalsDto({
    this.bondedTotal,
    this.redelegationTotal,
    this.unbondingTotal,
  });
  final BalanceDto? bondedTotal;
  final BalanceDto? redelegationTotal;
  final BalanceDto? unbondingTotal;

  // ignore: member-ordering
  factory DelegationTotalsDto.fromJson(Map<String, dynamic> json) =>
      _$DelegationTotalsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DelegationTotalsDtoToJson(this);
}
