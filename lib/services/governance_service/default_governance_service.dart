import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/client_coin_mixin.dart';
import 'package:provenance_wallet/services/governance_service/dtos/deposits_dto.dart';
import 'package:provenance_wallet/services/governance_service/dtos/height_dto.dart';
import 'package:provenance_wallet/services/governance_service/dtos/proposals_dto.dart';
import 'package:provenance_wallet/services/governance_service/dtos/votes_dto.dart';
import 'package:provenance_wallet/services/governance_service/governance_service.dart';
import 'package:provenance_wallet/services/models/block_height.dart';
import 'package:provenance_wallet/services/models/deposit.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/services/models/vote.dart';
import 'package:provenance_wallet/services/notification/client_notification_mixin.dart';

class DefaultGovernanceService extends GovernanceService
    with ClientNotificationMixin, ClientCoinMixin {
  @override
  Future<List<Proposal>> getProposals(
    Coin coin,
    int pageNumber,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      // FIXME: Replace this URL with the service's URL
      'https://service-explorer.test.provenance.io/api/v2/gov/proposals/all?count=50&page=$pageNumber',
      converter: (json) {
        if (json is String) {
          return <Proposal>[];
        }

        final List<Proposal> proposals = [];

        var dtos = ProposalsDto.fromJson(json);
        var test = dtos.results?.map((t) {
          return Proposal(dto: t);
        }).toList();

        if (test == null) {
          return <Proposal>[];
        }

        proposals.addAll(test);

        return proposals;
      },
    );

    notifyOnError(data);

    return data.data ?? [];
  }

  @override
  Future<BlockHeight> getHeight(
    Coin coin,
  ) async {
    //
    final client = await getClient(coin);
    final data = await client.get(
      // FIXME: Replace this URL with the service's URL
      'https://service-explorer.test.provenance.io/api/v2/blocks/height',
      converter: (json) {
        var dto = HeightDto.fromJson(json);

        return BlockHeight(dto: dto);
      },
    );

    notifyOnError(data);

    return data.data!;
  }

  @override
  Future<List<Vote>> getVotes(
    int proposalId,
    Coin coin,
    int pageNumber,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      // FIXME: Replace this URL with the service's URL
      'https://service-explorer.test.provenance.io/api/v2/gov/proposals/$proposalId/votes?count=50&page=$pageNumber',
      converter: (json) {
        if (json is String) {
          return <Vote>[];
        }

        final List<Vote> votes = [];

        var dtos = VotesDto.fromJson(json);
        var test = dtos.results?.map((t) {
          return Vote(dto: t);
        }).toList();

        if (test == null) {
          return <Vote>[];
        }

        votes.addAll(test);

        return votes;
      },
    );

    notifyOnError(data);

    return data.data ?? [];
  }

  @override
  Future<List<Vote>> getVotesForAddress(
    String address,
    Coin coin,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      // FIXME: Replace this URL with the service's URL
      'https://service-explorer.test.provenance.io/api/v2/gov/address/$address/votes',
      converter: (json) {
        if (json is String) {
          return <Vote>[];
        }

        final List<Vote> votes = [];

        var dtos = VotesDto.fromJson(json);
        var test = dtos.results?.map((t) {
          return Vote(dto: t);
        }).toList();

        if (test == null) {
          return <Vote>[];
        }

        votes.addAll(test);

        return votes;
      },
    );

    notifyOnError(data);

    return data.data ?? [];
  }

  @override
  Future<List<Deposit>> getDeposits(
    int proposalId,
    Coin coin,
    int pageNumber,
  ) async {
    final client = await getClient(coin);
    final data = await client.get(
      // FIXME: Replace this URL with the service's URL
      'https://service-explorer.test.provenance.io/api/v2/gov/proposals/$proposalId/deposits?count=50&page=$pageNumber',
      converter: (json) {
        if (json is String) {
          return <Deposit>[];
        }

        final List<Deposit> deposits = [];

        var dtos = DepositsDto.fromJson(json);
        var test = dtos.results?.map((t) {
          return Deposit(dto: t);
        }).toList();

        if (test == null) {
          return <Deposit>[];
        }

        deposits.addAll(test);

        return deposits;
      },
    );

    notifyOnError(data);

    return data.data ?? [];
  }
}