import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/balance_dto.dart';

part 'delegation_dto.g.dart';

@JsonSerializable()
class DelegationDto {
  DelegationDto({
    this.delegatorAddr,
    this.validatorSrcAddr,
    this.validatorDstAddr,
    this.amount,
    this.initialBal,
    this.block,
    this.endTime,
  });
  final String? delegatorAddr;
  final String? validatorSrcAddr;
  final String? validatorDstAddr;
  final BalanceDto? amount;
  final BalanceDto? initialBal;
  final int? block;
  final int? endTime;

  // ignore: member-ordering
  factory DelegationDto.fromJson(Map<String, dynamic> json) =>
      _$DelegationDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DelegationDtoToJson(this);
}
