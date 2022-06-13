import 'package:provenance_dart/proto.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class GovernanceService {
  Future<List<Any>> getProposals(
    Coin coin,
    int pageNumber,
  ) {
    //https://service-explorer.test.provenance.io/api/v2/gov/proposals/all?count=30&page=1
    throw Strings.notImplementedMessage;
  }

  Future<Any> getHeight(
    Coin coin,
  ) {
    //https://service-explorer.test.provenance.io/api/v2/blocks/height
    throw Strings.notImplementedMessage;
  }

  Future<List<Any>> getVotes(
    Coin coin,
    int pageNumber,
  ) {
    //https://service-explorer.test.provenance.io/api/v2/gov/proposals/36/votes?count=30&page=1
    throw Strings.notImplementedMessage;
  }

  Future<List<Any>> getDeposits(
    Coin coin,
    int pageNumber,
  ) {
    // https://service-explorer.test.provenance.io/api/v2/gov/proposals/23/deposits?count=30&page=1
    throw Strings.notImplementedMessage;
  }
}
