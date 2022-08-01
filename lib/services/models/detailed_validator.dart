import 'package:intl/intl.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/services/validator_service/dtos/detailed_validator_dto.dart';

class DetailedValidator {
  DetailedValidator({required DetailedValidatorDto dto})
      : assert(dto.blockCount != null),
        assert(dto.bondHeight != null),
        assert(dto.consensusPubKey != null),
        assert(dto.description != null),
        assert(dto.identity != null),
        assert(dto.moniker != null),
        assert(dto.operatorAddress != null),
        assert(dto.ownerAddress != null),
        assert(dto.siteUrl != null),
        assert(dto.status != null),
        assert(dto.uptime != null),
        assert(dto.withdrawalAddress != null),
        blockCount = dto.blockCount!.count!,
        blockTotal = dto.blockCount!.total!,
        bondHeight = dto.bondHeight!,
        consensusPubKey = dto.consensusPubKey!,
        description = dto.description!,
        identity = dto.identity!,
        imgUrl = dto.imgUrl,
        jailedUntil = dto.jailedUntil != null
            ? DateTime.fromMillisecondsSinceEpoch(dto.jailedUntil!.millis!)
            : null,
        moniker = dto.moniker!,
        operatorAddress = dto.operatorAddress!,
        ownerAddress = dto.ownerAddress!,
        siteUrl = dto.siteUrl!,
        status = ValidatorStatus.values
            .firstWhere((element) => element.name == dto.status!),
        unbondingHeight = dto.unbondingHeight,
        uptime = dto.uptime!,
        votingPowerCount = dto.votingPower?.count,
        votingPowerTotal = dto.votingPower?.total,
        withdrawalAddress = dto.withdrawalAddress!;

  DetailedValidator.fake({
    required this.blockCount,
    required this.blockTotal,
    required this.bondHeight,
    required this.consensusPubKey,
    required this.description,
    required this.identity,
    this.imgUrl,
    this.jailedUntil,
    required this.moniker,
    required this.operatorAddress,
    required this.ownerAddress,
    required this.siteUrl,
    required this.status,
    this.unbondingHeight,
    required this.uptime,
    this.votingPowerCount,
    this.votingPowerTotal,
    required this.withdrawalAddress,
  });
  final int blockCount;
  final int blockTotal;
  final int bondHeight;
  final String consensusPubKey;
  final String description;
  final String identity;
  final String? imgUrl;
  final DateTime? jailedUntil;
  final String moniker;
  final String operatorAddress;
  final String ownerAddress;
  final String siteUrl;
  final ValidatorStatus status;
  final int? unbondingHeight;
  final double uptime;
  final int? votingPowerCount;
  final int? votingPowerTotal;
  final String withdrawalAddress;

  String get formattedJailedUntil {
    return jailedUntil != null
        ? DateFormat.yMMMd('en_US').add_Hms().format(jailedUntil!)
        : "";
  }

  String get formattedVotingPower {
    return votingPowerCount != null && votingPowerCount != null
        ? "${((votingPowerCount! / votingPowerTotal!) * 100).toStringAsFixed(2)}%"
        : "0 %";
  }
}
