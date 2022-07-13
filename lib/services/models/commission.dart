import 'package:provenance_wallet/services/validator_service/dtos/commission_dto.dart';
import 'package:provenance_wallet/util/denom_util.dart';
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
  final int bondedTokensCount;
  final String bondedTokensDenom;
  final int selfBondedCount;
  final String selfBondedDenom;
  final int delegatorBondedCount;
  final String delegatorBondedDenom;
  final int delegatorCount;
  final String totalShares;
  final String commissionRewardsAmount;
  final String commissionRewardsDenom;
  final String commissionRate;
  final String commissionMaxRate;
  final String commissionMaxChangeRate;

  String get formattedTotalShares {
    return totalShares.formatNumber().split(".")[0];
  }

  String get formattedBondedTokens {
    return Strings.stakingConfirmHashAmount(
        nHashToHash(BigInt.from(bondedTokensCount), fractionDigits: 7)
            .toString());
  }

  String get formattedRewards {
    var rewards = stringNHashToHash(commissionRewardsAmount, fractionDigits: 7)
        .toString()
        .formatNumber();
    return Strings.stakingConfirmHashAmount(rewards);
  }
}
