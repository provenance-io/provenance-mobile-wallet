import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_client/dtos/block_count_dto.dart';
import 'package:provenance_wallet/services/validator_client/dtos/voting_power_dto.dart';

part 'detailed_validator_dto.g.dart';

@JsonSerializable()
class DetailedValidatorDto {
  DetailedValidatorDto({
    this.blockCount,
    this.bondHeight,
    this.consensusPubKey,
    this.description,
    this.identity,
    this.imgUrl,
    this.jailedUntil,
    this.moniker,
    this.operatorAddress,
    this.ownerAddress,
    this.siteUrl,
    this.status,
    this.unbondingHeight,
    this.uptime,
    this.votingPower,
    this.withdrawalAddress,
  });
  final BlockCountDto? blockCount;
  final int? bondHeight;
  final String? consensusPubKey;
  final String? description;
  final String? identity;
  final String? imgUrl;
  final String? jailedUntil;
  final String? moniker;
  final String? operatorAddress;
  final String? ownerAddress;
  final String? siteUrl;
  final String? status;
  final int? unbondingHeight;
  final double? uptime;
  final VotingPowerDto? votingPower;
  final String? withdrawalAddress;

  // ignore: member-ordering
  factory DetailedValidatorDto.fromJson(Map<String, dynamic> json) =>
      _$DetailedValidatorDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DetailedValidatorDtoToJson(this);
}
