import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/block_height.dart';
import 'package:provenance_wallet/services/models/deposit.dart';
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

  Future<BlockHeight> getHeight(
    Coin coin,
  ) {
    //https://service-explorer.test.provenance.io/api/v2/blocks/height
    throw Strings.notImplementedMessage;
  }

  Future<List<Vote>> getVotes(
    Coin coin,
    int pageNumber,
  ) {
    //https://service-explorer.test.provenance.io/api/v2/gov/proposals/36/votes?count=30&page=1
    throw Strings.notImplementedMessage;
  }

  Future<List<Deposit>> getDeposits(
    Coin coin,
    int pageNumber,
  ) {
    // https://service-explorer.test.provenance.io/api/v2/gov/proposals/23/deposits?count=30&page=1
    throw Strings.notImplementedMessage;
  }
}
