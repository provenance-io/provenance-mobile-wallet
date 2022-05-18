import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/balance_dto.dart';

part 'redelegation_totals_dto.g.dart';

@JsonSerializable()
class RedelegationTotalsDto {
  RedelegationTotalsDto({
    this.redelegationTotal,
  });
  final BalanceDto? redelegationTotal;

  // ignore: member-ordering
  factory RedelegationTotalsDto.fromJson(Map<String, dynamic> json) =>
      _$RedelegationTotalsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RedelegationTotalsDtoToJson(this);
}
