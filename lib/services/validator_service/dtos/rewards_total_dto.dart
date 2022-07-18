import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/reward_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/rewards_dto.dart';

part 'rewards_total_dto.g.dart';

@JsonSerializable()
class RewardsTotalDto {
  RewardsTotalDto(
    this.rewards,
    this.total,
  );

  final List<RewardsDto>? rewards;
  final List<RewardDto>? total;

  // ignore: member-ordering
  factory RewardsTotalDto.fromJson(Map<String, dynamic> json) =>
      _$RewardsTotalDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RewardsTotalDtoToJson(this);
}
