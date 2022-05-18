import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/balance_dto.dart';

part 'delegation_totals_dto.g.dart';

@JsonSerializable()
class DelegationTotalsDto {
  DelegationTotalsDto({
    this.bondedTotal,
  });
  final BalanceDto? bondedTotal;

  // ignore: member-ordering
  factory DelegationTotalsDto.fromJson(Map<String, dynamic> json) =>
      _$DelegationTotalsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DelegationTotalsDtoToJson(this);
}
