import 'package:provenance_wallet/services/validator_service/dtos/commission_dto.dart';
import 'package:provenance_wallet/util/strings.dart';

class Commission {
  Commission({required CommissionDto dto})
      : assert(dto.bondedTokens?.count != null),
        assert(dto.bondedTokens?.denom != null),
        assert(dto.selfBonded?.count != null),
        assert(dto.selfBonded?.denom != null),
        assert(dto.delegatorBonded?.count != null),
        assert(dto.delegatorBonded?.denom != null),
        assert(dto.commissionRate?.rate != null),
        assert(dto.commissionRate?.maxRate != null),
        assert(dto.commissionRate?.maxChangeRate != null),
        assert(dto.commissionRewards?.amount != null),
        assert(dto.commissionRewards?.denom != null),
        bondedTokensCount = dto.bondedTokens!.count!,
        bondedTokensDenom = dto.bondedTokens!.denom!,
        selfBondedCount = dto.selfBonded!.count!,
        selfBondedDenom = dto.selfBonded!.denom!,
        delegatorBondedCount = dto.delegatorBonded!.count!,
        delegatorBondedDenom = dto.delegatorBonded!.denom!,
        delegatorCount = dto.delegatorCount!,
        totalShares = dto.totalShares!,
        commissionRewardsAmount = dto.commissionRewards!.amount!,
        commissionRewardsDenom = dto.commissionRewards!.denom!,
        commissionRate = "${num.parse(dto.commissionRate!.rate!) * 100}%",
        commissionMaxRate = "${num.parse(dto.commissionRate!.maxRate!) * 100}%",
        commissionMaxChangeRate =
            "${num.parse(dto.commissionRate!.maxChangeRate!) * 100}%";

  Commission.fake({
    required this.bondedTokensCount,
    required this.bondedTokensDenom,
    required this.selfBondedCount,
    required this.selfBondedDenom,
    required this.delegatorBondedCount,
    required this.delegatorBondedDenom,
    required this.delegatorCount,
    required this.totalShares,
    required this.commissionRewardsAmount,
    required this.commissionRewardsDenom,
    required this.commissionRate,
    required this.commissionMaxRate,
    required this.commissionMaxChangeRate,
  });
  final String bondedTokensCount;
  final String bondedTokensDenom;
  final String selfBondedCount;
  final String selfBondedDenom;
  final String delegatorBondedCount;
  final String delegatorBondedDenom;
  final int delegatorCount;
  final String totalShares;
  final String commissionRewardsAmount;
  final String commissionRewardsDenom;
  final String commissionRate;
  final String commissionMaxRate;
  final String commissionMaxChangeRate;

  String get formattedTotalShares {
    return totalShares.split('.')[0].formatNumber();
  }

  String get formattedBondedTokens {
    var tokens = bondedTokensCount.nhashToHash(fractionDigits: 7).split('.');
    return '${tokens[0].formatNumber()}.${tokens[1]} hash';
  }

  String get formattedRewards {
    var rewards =
        commissionRewardsAmount.nhashToHash(fractionDigits: 7).split('.');
    return '${rewards[0].formatNumber()}.${rewards[1]} hash';
  }
}
