import 'package:provenance_blockchain_wallet/services/models/onboarding_stat.dart';
import 'package:provenance_blockchain_wallet/util/strings.dart';
import 'package:provenance_dart/wallet.dart';

abstract class StatService {
  Future<OnboardingStat?> getStats(Coin coin) {
    throw Strings.notImplementedMessage;
  }
}
