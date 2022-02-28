import 'dart:math';

import 'package:provenance_wallet/common/models/onboarding_stat.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class StatService {
  Future<OnboardingStat?> getStats() {
    throw Strings.notImplementedMessage;
  }
}
