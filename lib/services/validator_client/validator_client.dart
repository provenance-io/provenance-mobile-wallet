import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class ValidatorClient {
  Future<List<ProvenanceValidator>> getRecentValidators(
    Coin coin,
    int pageNumber,
  ) {
    throw Strings.notImplementedMessage;
  }

  Future<List<Delegation>> getDelegations(
    Coin coin,
    String provenanceAddress,
    int pageNumber,
  ) {
    throw Strings.notImplementedMessage;
  }

  Future<List<Rewards>> getRewards(
    Coin coin,
    String provenanceAddress,
  ) {
    throw Strings.notImplementedMessage;
  }

  Future<DetailedValidator> getDetailedValidator(
    Coin coin,
    String validatorAddress,
  ) {
    throw Strings.notImplementedMessage;
  }

  Future<Commission> getValidatorCommission(
    Coin coin,
    String validatorAddress,
  ) {
    throw Strings.notImplementedMessage;
  }
}
