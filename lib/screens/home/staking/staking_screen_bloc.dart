import 'dart:async';

import 'package:provenance_wallet/common/classes/pw_paging_cache.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/extension/list_extension.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/services/validator_client/validator_client.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class StakingScreenBloc extends PwPagingCache {
  final _isLoading = BehaviorSubject.seeded(false);
  final _isLoadingValidators = BehaviorSubject.seeded(false);
  final _isLoadingDelegations = BehaviorSubject.seeded(false);
  final _stakingDetails = BehaviorSubject.seeded(
    StakingDetails(address: "", delegates: [], validators: [], rewards: []),
  );
  final _validatorPages = BehaviorSubject.seeded(1);
  final _delegationPages = BehaviorSubject.seeded(1);
  final _validatorClient = get<ValidatorClient>();
  final TransactableAccount _account;

  final Function onFlowCompletion;

  StakingScreenBloc({
    required this.onFlowCompletion,
  })  : _account = get<AccountService>().events.selected.value!,
        super(50);

  ValueStream<StakingDetails> get stakingDetails => _stakingDetails;
  ValueStream<bool> get isLoading => _isLoading;
  ValueStream<bool> get isLoadingValidators => _isLoadingValidators;
  ValueStream<bool> get isLoadingDelegations => _isLoadingDelegations;

  @override
  FutureOr onDispose() {
    _isLoading.close();
    _isLoadingValidators.close();
    _isLoadingDelegations.close();
    _stakingDetails.close();
    _validatorPages.close();
    _delegationPages.close();
  }

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading.tryAdd(true);
    }

    try {
      final delegations = await _validatorClient.getDelegations(
        _account.coin,
        _account.address,
        _delegationPages.value,
      );

      final rewards = await _validatorClient.getRewards(
        _account.coin,
        _account.address,
      );

      final validators = await _validatorClient.getRecentValidators(
        _account.coin,
        _validatorPages.value,
      );

      _stakingDetails.tryAdd(
        StakingDetails(
            delegates: delegations,
            validators: validators,
            address: _account.address,
            rewards: rewards),
      );
    } finally {
      if (showLoading) {
        _isLoading.tryAdd(false);
      }
    }
  }

  Future<void> updateSort(ValidatorSortingState selectedSort) async {
    final oldDetails = _stakingDetails.value;

    if (selectedSort == oldDetails.selectedSort) {
      return;
    }

    _isLoading.tryAdd(true);

    _delegationPages.value = 1;
    try {
      _stakingDetails.tryAdd(
        StakingDetails(
          delegates: oldDetails.delegates,
          validators: selectedSort.sort(oldDetails.validators),
          address: oldDetails.address,
          selectedSort: selectedSort,
          rewards: oldDetails.rewards,
        ),
      );
    } finally {
      _isLoading.tryAdd(false);
    }
  }

  Future<void> loadAdditionalDelegates() async {
    var oldDetails = _stakingDetails.value;

    final delegates = await loadMore(
        oldDetails.delegates,
        _delegationPages,
        _isLoadingDelegations,
        () async => await _validatorClient.getDelegations(
            _account.coin, _account.address, _delegationPages.value));

    _stakingDetails.tryAdd(
      StakingDetails(
        delegates: delegates,
        validators: oldDetails.validators,
        address: oldDetails.address,
        selectedSort: oldDetails.selectedSort,
        rewards: oldDetails.rewards,
      ),
    );

    _isLoadingValidators.value = false;
  }

  Future<void> loadAdditionalValidators() async {
    var oldDetails = _stakingDetails.value;

    final validators = await loadMore(
      oldDetails.validators,
      _validatorPages,
      _isLoadingValidators,
      () async => await _validatorClient.getRecentValidators(
        _account.coin,
        _validatorPages.value,
      ),
    );

    _stakingDetails.tryAdd(
      StakingDetails(
        delegates: oldDetails.delegates,
        validators: oldDetails.selectedSort.sort(validators),
        address: oldDetails.address,
        selectedSort: oldDetails.selectedSort,
        rewards: oldDetails.rewards,
      ),
    );

    _isLoadingValidators.value = false;
  }

  Future<void> showMenu(
    BuildContext context,
  ) async {
    var result = await showModalBottomSheet<ValidatorSortingState>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PwGreyButton(
              text: Strings.of(context).menuAlphabetically,
              onPressed: () {
                Navigator.of(context).pop(ValidatorSortingState.alphabetically);
              },
            ),
            PwListDivider(),
            PwGreyButton(
              text: Strings.of(context).menuCommission,
              onPressed: () {
                Navigator.of(context).pop(ValidatorSortingState.commission);
              },
            ),
            PwListDivider(),
            PwGreyButton(
              text: Strings.of(context).menuDelegators,
              onPressed: () {
                Navigator.of(context).pop(ValidatorSortingState.delegators);
              },
            ),
            PwListDivider(),
            PwGreyButton(
              text: Strings.of(context).menuVotingPower,
              onPressed: () {
                Navigator.of(context).pop(ValidatorSortingState.votingPower);
              },
            ),
            PwListDivider(),
            PwGreyButton(
              enabled: false,
              text: "",
              // ignore: no-empty-block
              onPressed: () {},
            ),
          ],
        );
      },
    );
    if (result != null) {
      updateSort(result);
    }
  }
}

class StakingDetails {
  StakingDetails({
    required this.delegates,
    required this.validators,
    required this.rewards,
    this.selectedSort = ValidatorSortingState.votingPower,
    required this.address,
  });

  final List<Delegation> delegates;
  final List<ProvenanceValidator> validators;
  final List<Rewards> rewards;
  final ValidatorSortingState selectedSort;
  final String address;
}

enum ValidatorSortingState {
  votingPower,
  delegators,
  commission,
  alphabetically,
}

enum ValidatorStatus {
  active,
  candidate,
  jailed,
}

extension ValidatorSortingStateExtension on ValidatorSortingState {
  List<ProvenanceValidator> sort(List<ProvenanceValidator> validators) {
    switch (this) {
      case ValidatorSortingState.votingPower:
        validators.sortDescendingWithFallback(
          get: (v) => v.votingPower,
          fallback: (v) => v.moniker,
        );
        break;
      case ValidatorSortingState.delegators:
        validators.sortDescendingWithFallback(
          get: (v) => v.delegators,
          fallback: (v) => v.moniker,
        );
        break;
      case ValidatorSortingState.commission:
        validators.sortDescendingWithFallback(
          get: (v) => v.rawCommission,
          fallback: (v) => v.moniker,
        );
        break;
      case ValidatorSortingState.alphabetically:
        validators.sortAscendingBy((v) => v.moniker);
        break;
    }
    return validators.toList();
  }
}
