import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_client/dtos/balance_dto.dart';

part 'reward_dto.g.dart';

@JsonSerializable()
class RewardDto {
  RewardDto(
    this.amount,
    this.denom,
    this.pricePerToken,
    this.totalBalancePrice,
  );
  final String? amount;
  final String? denom;
  final BalanceDto? pricePerToken;
  final BalanceDto? totalBalancePrice;

  // ignore: member-ordering
  factory RewardDto.fromJson(Map<String, dynamic> json) =>
      _$RewardDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RewardDtoToJson(this);
}
