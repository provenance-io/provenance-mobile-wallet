import 'package:provenance_wallet/network/dtos/stat_dto.dart';

class OnboardingStat {
  OnboardingStat({required StatDto dto})
      : assert(dto.averageBlockTime != null),
        assert(dto.marketCap != null),
        assert(dto.transactions != null),
        assert(dto.validators != null),
        marketCap = '\$${(dto.marketCap! / 1000000000).toStringAsFixed(1)}B',
        validators = dto.validators!,
        transactions = '${(dto.transactions! / 1000).toStringAsFixed(1)}k',
        blockTime = '${dto.averageBlockTime!}sec';

  OnboardingStat.fake({
    required this.marketCap,
    required this.validators,
    required this.transactions,
    required this.blockTime,
  });

  String marketCap;
  int validators;
  String transactions;
  String blockTime;
}
