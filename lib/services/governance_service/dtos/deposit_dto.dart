import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/governance_service/dtos/proposer_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/balance_dto.dart';

part 'deposit_dto.g.dart';

@JsonSerializable()
class DepositDto {
  DepositDto({
    this.voter,
    this.type,
    this.amount,
    this.blockHeight,
    this.txHash,
    this.txTimestamp,
  });

  final ProposerDto? voter;
  final String? type;
  final BalanceDto? amount;
  final int? blockHeight;
  final String? txHash;
  final DateTime? txTimestamp;

  // ignore: member-ordering
  factory DepositDto.fromJson(Map<String, dynamic> json) =>
      _$DepositDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DepositDtoToJson(this);
}
