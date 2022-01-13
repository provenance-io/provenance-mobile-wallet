import 'dart:math';

class StatService {
  factory StatService() => _singleton;
  StatService._internal();

  static final StatService _singleton = StatService._internal();

  static StatService get instance => _singleton;

  // TODO: Do this, but for reals.
  static Future<OnboardingStat> getStats() async {
    await Future.delayed(Duration(milliseconds: 500));
    var random = new Random();

    return OnboardingStat(
      '\$${random.nextInt(5) + 10}.${random.nextInt(9)}B',
      random.nextInt(5) + 10,
      '${random.nextInt(395) + 400}.${random.nextInt(9)}K',
      '${random.nextInt(6) + 2}.${random.nextInt(99)} sec.',
    );
  }
}

class OnboardingStat {
  OnboardingStat(
    this.marketCap,
    this.validators,
    this.transactions,
    this.blockTime,
  );

  String marketCap;
  int validators;
  String transactions;
  String blockTime;
}
