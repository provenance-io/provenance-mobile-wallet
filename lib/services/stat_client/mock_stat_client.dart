import 'dart:math';

import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/onboarding_stat.dart';
import 'package:provenance_wallet/services/stat_client/stat_client.dart';

class MockStatClient extends StatClient {
  @override
  Future<OnboardingStat?> getStats(Coin coin) async {
    await Future.delayed(Duration(milliseconds: 500));
    var random = Random();

    return OnboardingStat.fake(
      marketCap: '\$${random.nextInt(5) + 10}.${random.nextInt(9)}B',
      validators: random.nextInt(5) + 10,
      transactions: '${random.nextInt(395) + 400}.${random.nextInt(9)}k',
      blockTime: '${random.nextInt(6) + 2}.${random.nextInt(99)}sec',
    );
  }
}
