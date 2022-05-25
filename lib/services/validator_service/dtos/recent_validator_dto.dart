import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/bonded_tokens_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/voting_power_dto.dart';

part 'recent_validator_dto.g.dart';

@JsonSerializable()
class RecentValidatorDto {
  RecentValidatorDto({
    this.moniker,
    this.addressId,
    this.consensusAddress,
    this.proposerPriority,
    this.votingPower,
    this.commission,
    this.bondedTokens,
    this.delegators,
    this.status,
    this.imgUrl,
    this.hr24Change,
    this.uptime,
  });
  final String? moniker;
  final String? addressId;
  final String? consensusAddress;
  final int? proposerPriority;
  final VotingPowerDto? votingPower;
  final String? commission;
  final BondedTokensDto? bondedTokens;
  final int? delegators;
  final String? status;
  final String? imgUrl;
  final String? hr24Change;
  final double? uptime;

  // ignore: member-ordering
  factory RecentValidatorDto.fromJson(Map<String, dynamic> json) =>
      _$RecentValidatorDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RecentValidatorDtoToJson(this);
}
