import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/home/explorer/explorer_bloc.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/services/models/validator_delegate.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class ValidatorService {
  Future<List<ProvenanceValidator>> getRecentValidators(
    Coin coin,
    int pageNumber,
    ValidatorStatus status,
  ) {
    throw Strings.notImplementedMessage;
  }

  Future<List<ValidatorDelegate>> getDelegations(
    Coin coin,
    String provenanceAddress,
    int pageNumber,
    ValidatorType type,
  ) {
    throw Strings.notImplementedMessage;
  }

  Future<List<Rewards>> getRewards(
    Coin coin,
    String provenanceAddress,
  ) {
    throw Strings.notImplementedMessage;
  }
}
