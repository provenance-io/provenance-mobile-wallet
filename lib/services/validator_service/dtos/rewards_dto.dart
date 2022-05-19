import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/reward_dto.dart';

part 'rewards_dto.g.dart';

@JsonSerializable()
class RewardsDto {
  RewardsDto(
    this.reward,
    this.validatorAddress,
  );
  final List<RewardDto> reward;
  final String? validatorAddress;

  // ignore: member-ordering
  factory RewardsDto.fromJson(Map<String, dynamic> json) =>
      _$RewardsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RewardsDtoToJson(this);
}
