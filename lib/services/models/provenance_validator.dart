import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/services/validator_service/dtos/recent_validator_dto.dart';

class ProvenanceValidator {
  ProvenanceValidator({
    required RecentValidatorDto dto,
  })  : assert(dto.moniker != null),
        assert(dto.addressId != null),
        assert(dto.consensusAddress != null),
        assert(dto.commission != null),
        assert(num.tryParse(dto.commission!) != null),
        assert(dto.delegators != null),
        assert(dto.status != null),
        assert(dto.uptime != null),
        moniker = dto.moniker!,
        addressId = dto.addressId!,
        consensusAddress = dto.consensusAddress!,
        commission =
            '${(num.tryParse(dto.commission!)! * 100).toStringAsFixed(0)}%',
        rawCommission = double.parse(dto.commission!),
        delegators = dto.delegators!,
        status = ValidatorStatus.values
            .firstWhere((element) => element.name == dto.status!),
        uptime = dto.uptime!,
        proposerPriority = dto.proposerPriority,
        votingPowerCount = dto.votingPower?.count,
        votingPowerTotal = dto.votingPower?.total,
        bondedTokensCount = dto.bondedTokens?.count,
        bondedTokensDenom = dto.bondedTokens?.denom,
        bondedTokensTotal = dto.bondedTokens?.total,
        imgUrl = dto.imgUrl,
        hr24Change = dto.hr24Change;

  ProvenanceValidator.fake({
    required this.moniker,
    required this.addressId,
    required this.consensusAddress,
    required this.commission,
    required this.rawCommission,
    required this.delegators,
    required this.status,
    required this.uptime,
    this.proposerPriority,
    this.votingPowerCount,
    this.votingPowerTotal,
    this.bondedTokensCount,
    this.bondedTokensDenom,
    this.bondedTokensTotal,
    this.imgUrl,
    this.hr24Change,
  });

  final String moniker;
  final String addressId;
  final String consensusAddress;
  final int? proposerPriority;
  final int? votingPowerCount;
  final int? votingPowerTotal;
  final String commission;
  final double rawCommission;
  final String? bondedTokensCount;
  final String? bondedTokensTotal;
  final String? bondedTokensDenom;
  final int delegators;
  final ValidatorStatus status;
  final String? imgUrl;
  final String? hr24Change;
  final double uptime;

  double get votingPower {
    if (votingPowerCount == null ||
        votingPowerCount == 0 ||
        votingPowerTotal == null ||
        votingPowerTotal == 0) {
      return 0;
    }
    return (votingPowerCount! / votingPowerTotal!) * 100;
  }
}
