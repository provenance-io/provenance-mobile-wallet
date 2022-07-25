import 'package:provenance_wallet/services/validator_service/dtos/reward_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/rewards_dto.dart';
import 'package:provenance_wallet/util/denom_util.dart';
import 'package:provenance_wallet/util/strings.dart';

class Rewards {
  Rewards({required RewardsDto dto})
      : assert(dto.reward != null),
        assert(dto.validatorAddress != null),
        rewards = dto.reward!.map((e) => Reward(dto: e)).toList(),
        validatorAddress = dto.validatorAddress!;

  Rewards.fake(
    this.rewards,
    this.validatorAddress,
  );
  final List<Reward> rewards;
  final String validatorAddress;
}

class Reward {
  Reward({required RewardDto dto})
      : assert(dto.amount != null),
        assert(dto.denom != null),
        assert(dto.pricePerToken?.amount != null),
        assert(dto.totalBalancePrice?.amount != null),
        amount = dto.amount!,
        denom = dto.denom!,
        pricePerToken = dto.pricePerToken!.amount!,
        totalBalancePrice = dto.totalBalancePrice!.amount!;
  Reward.fake(
    this.amount,
    this.denom,
    this.pricePerToken,
    this.totalBalancePrice,
  );
  final String amount;
  final String denom;
  final String pricePerToken;
  final String totalBalancePrice;

  String get formattedAmount {
    return stringNHashToHash(amount, fractionDigits: 7)
        .toString()
        .formatNumber();
  }
}
