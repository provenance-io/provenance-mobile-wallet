import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/home/explorer/explorer_bloc.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class ValidatorService {
  Future<List<ProvenanceValidator>> getRecentValidators(
    Coin coin,
    int pageNumber,
    ValidatorStatus status,
  ) {
    throw Strings.notImplementedMessage;
  }

  Future<List<Delegation>> getDelegations(
    Coin coin,
    String provenanceAddress,
    int pageNumber,
    DelegationState state,
  ) {
    throw Strings.notImplementedMessage;
  }
}
