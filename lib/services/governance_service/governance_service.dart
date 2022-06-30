import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/services/models/vote.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class GovernanceService {
  Future<List<Proposal>> getProposals(
    Coin coin,
    int pageNumber,
  ) {
    //https://service-explorer.test.provenance.io/api/v2/gov/proposals/all?count=30&page=1
    throw Strings.notImplementedMessage;
  }

  Future<List<Vote>> getVotesForAddress(
    String address,
    Coin coin,
  ) {
    // https://service-explorer.test.provenance.io/api/v2/gov/address/{address}/votes?count=50&page=1
    throw Strings.notImplementedMessage;
  }
}
