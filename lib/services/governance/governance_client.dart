import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/services/models/vote.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class GovernanceClient {
  Future<List<Proposal>> getProposals(
    Coin coin,
    int pageNumber,
  ) {
    throw Strings.notImplementedMessage;
  }

  Future<List<Vote>> getVotesForAddress(
    String address,
    Coin coin,
  ) {
    throw Strings.notImplementedMessage;
  }
}
