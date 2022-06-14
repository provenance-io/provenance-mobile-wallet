import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/voting_power_dto.dart';

part 'height_dto.g.dart';

@JsonSerializable()
class HeightDto {
  HeightDto({
    this.height,
    this.hash,
    this.time,
    this.proposerAddress,
    this.moniker,
    this.icon,
    this.votingPower,
    this.validatorCount,
    this.txNum,
  });

  final int? height;
  final String? hash;
  final DateTime? time;
  final String? proposerAddress;
  final String? moniker;
  final String? icon;
  final VotingPowerDto? votingPower;
  final VotingPowerDto? validatorCount;
  final int? txNum;

  // ignore: member-ordering
  factory HeightDto.fromJson(Map<String, dynamic> json) =>
      _$HeightDtoFromJson(json);
  Map<String, dynamic> toJson() => _$HeightDtoToJson(this);
}
