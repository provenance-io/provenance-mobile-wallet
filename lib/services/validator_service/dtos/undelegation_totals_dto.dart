import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/balance_dto.dart';

part 'undelegation_totals_dto.g.dart';

@JsonSerializable()
class UndelegationTotalsDto {
  UndelegationTotalsDto({
    this.redelegationTotal,
  });
  final BalanceDto? redelegationTotal;

  // ignore: member-ordering
  factory UndelegationTotalsDto.fromJson(Map<String, dynamic> json) =>
      _$UndelegationTotalsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UndelegationTotalsDtoToJson(this);
}
