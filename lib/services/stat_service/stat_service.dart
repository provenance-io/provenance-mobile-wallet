import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/onboarding_stat.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class StatService {
  Future<OnboardingStat?> getStats(Coin coin) {
    throw Strings.notImplementedMessage;
  }
}
