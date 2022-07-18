import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/balance_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/bonded_tokens_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/commission_rate_dto.dart';

part 'commission_dto.g.dart';

@JsonSerializable()
class CommissionDto {
  CommissionDto(
      {this.bondedTokens,
      this.selfBonded,
      this.delegatorBonded,
      this.delegatorCount,
      this.totalShares,
      this.commissionRewards,
      this.commissionRate});
  final BondedTokensDto? bondedTokens;
  final BondedTokensDto? selfBonded;
  final BondedTokensDto? delegatorBonded;
  final int? delegatorCount;
  final String? totalShares;
  final BalanceDto? commissionRewards;
  final CommissionRateDto? commissionRate;

  // ignore: member-ordering
  factory CommissionDto.fromJson(Map<String, dynamic> json) =>
      _$CommissionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CommissionDtoToJson(this);
}
