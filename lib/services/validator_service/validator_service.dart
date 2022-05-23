import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/abbreviated_validator.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class ValidatorService {
  Future<List<ProvenanceValidator>> getRecentValidators(
    Coin coin,
    String provenanceAddress,
    int pageNumber,
    String status,
  ) {
    throw Strings.notImplementedMessage;
  }

  Future<List<AbbreviatedValidator>> getAbbreviatedValidators(
    Coin coin,
    int pageNumber,
  ) {
    throw Strings.notImplementedMessage;
  }
}
