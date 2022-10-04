import 'dart:async';

import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/classes/pw_paging_cache.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/governance_service/governance_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/services/models/vote.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class ProposalsBloc extends PwPagingCache {
  final _isLoading = BehaviorSubject.seeded(false);
  final _isLoadingProposals = BehaviorSubject.seeded(false);
  final _proposalDetails = BehaviorSubject.seeded(
    ProposalDetails(proposals: [], myVotes: [], asset: null),
  );
  final _proposalPages = BehaviorSubject.seeded(1);
  final _governanceService = get<GovernanceService>();
  final TransactableAccount _account;

  ProposalsBloc({
    required TransactableAccount account,
  })  : _account = account,
        super(50);

  ValueStream<ProposalDetails> get proposalDetails => _proposalDetails;
  ValueStream<bool> get isLoading => _isLoading;
  ValueStream<bool> get isLoadingProposals => _isLoadingProposals;

  @override
  FutureOr onDispose() {
    _isLoading.close();
    _isLoadingProposals.close();
    _proposalDetails.close();
    _proposalPages.close();
  }

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading.tryAdd(true);
    }

    try {
      _proposalPages.tryAdd(1);
      final asset =
          (await get<AssetService>().getAssets(_account.coin, _account.address))
              .firstWhere((element) => element.denom == 'nhash');
      final proposals = await _governanceService.getProposals(
        _account.coin,
        _proposalPages.value,
      );

      final myVotes = await _governanceService.getVotesForAddress(
        _account.address,
        _account.coin,
      );

      _proposalDetails.tryAdd(
        ProposalDetails(
          proposals: proposals,
          myVotes: myVotes,
          asset: asset,
        ),
      );
    } finally {
      if (showLoading) {
        _isLoading.tryAdd(false);
      }
    }
  }

  Future<void> loadAdditionalProposals() async {
    var oldDetails = _proposalDetails.value;

    final proposals = await loadMore(
        oldDetails.proposals,
        _proposalPages,
        _isLoadingProposals,
        () async => await _governanceService.getProposals(
            _account.coin, _proposalPages.value));

    _proposalDetails.tryAdd(
      ProposalDetails(
        proposals: proposals,
        myVotes: oldDetails.myVotes,
        asset: oldDetails.asset,
      ),
    );

    _isLoadingProposals.value = false;
  }

  Color getColor(String status, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case passed:
        return colorScheme.positive300;
      case rejected:
        return colorScheme.error;
      case votingPeriod:
        return colorScheme.terciary350;
      case depositPeriod:
        return colorScheme.notice325;
      case vetoed:
        return colorScheme.neutral200;
      default:
        return colorScheme.neutral200;
    }
  }

  String getExplorerUrl(String address) {
    switch (_account.coin) {
      case Coin.mainNet:
        return "https://explorer.provenance.io/accounts/$address";
      default:
        return "https://explorer.test.provenance.io/accounts/$address";
    }
  }
}

class ProposalDetails {
  ProposalDetails({
    required this.proposals,
    required this.myVotes,
    required this.asset,
  });

  final List<Proposal> proposals;
  final List<Vote> myVotes;
  final Asset? asset;
}
