import 'dart:async';

import 'package:provenance_wallet/common/classes/pw_paging_cache.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/services/validator_service/validator_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class StakingFlowBloc extends PwPagingCache implements StakingFlowNavigator {
  final _isLoading = BehaviorSubject.seeded(false);
  final _isLoadingValidators = BehaviorSubject.seeded(false);
  final _isLoadingDelegations = BehaviorSubject.seeded(false);
  final _stakingDetails = BehaviorSubject.seeded(
    StakingDetails(address: "", delegates: [], validators: [], rewards: []),
  );
  final _validatorPages = BehaviorSubject.seeded(1);
  final _delegationPages = BehaviorSubject.seeded(1);
  final _validatorService = get<ValidatorService>();
  final Account _account;
  final StakingFlowNavigator _navigator;

  StakingFlowBloc({
    required Account account,
    required StakingFlowNavigator navigator,
  })  : _account = account,
        _navigator = navigator,
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
      final account = _account;

      final delegations = await _validatorService.getDelegations(
        _account.publicKey!.coin,
        _account.publicKey!.address,
        _delegationPages.value,
      );

      final rewards = await _validatorService.getRewards(
          account.publicKey!.coin, account.publicKey!.address);

      final validators = await _validatorService.getRecentValidators(
        _account.publicKey!.coin,
        _validatorPages.value,
      );

      _stakingDetails.tryAdd(
        StakingDetails(
            delegates: delegations,
            validators: validators,
            address: account.publicKey!.address,
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
        () async => await _validatorService.getDelegations(
            _account.publicKey!.coin,
            _account.publicKey!.address,
            _delegationPages.value));

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
        () async => await _validatorService.getRecentValidators(
              _account.publicKey!.coin,
              _validatorPages.value,
            ));

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

  @override
  void onComplete() {
    _navigator.onComplete();
  }

  @override
  Future<void> showClaimRewardsReview(DetailedValidator validator) async {
    _navigator.showClaimRewardsReview(validator);
  }

  @override
  Future<void> showDelegationReview() async {
    _navigator.showDelegationReview();
  }

  @override
  Future<void> showDelegationScreen(
    DetailedValidator validator,
    Commission commission,
  ) async {
    _navigator.showDelegationScreen(validator, commission);
  }

  @override
  Future<void> showRedelegationReview() async {
    _navigator.showRedelegationReview();
  }

  @override
  Future<void> showRedelegationScreen(
    DetailedValidator validator,
  ) async {
    _navigator.showRedelegationScreen(validator);
  }

  @override
  Future<void> showTransactionData(String data) async {
    _navigator.showTransactionData(data);
  }

  @override
  Future<void> showTransactionSuccess(SelectedDelegationType selected) async {
    _navigator.showTransactionSuccess(selected);
  }

  @override
  Future<void> showUndelegationReview() async {
    _navigator.showUndelegationReview();
  }

  @override
  Future<void> showUndelegationScreen(DetailedValidator validator) async {
    _navigator.showUndelegationScreen(validator);
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
  String get dropDownTitle {
    switch (this) {
      case ValidatorSortingState.votingPower:
        return Strings.dropDownVotingPower;
      case ValidatorSortingState.delegators:
      case ValidatorSortingState.commission:
        return name.capitalize();
      case ValidatorSortingState.alphabetically:
        return Strings.dropDownAlphabetically;
    }
  }

  List<ProvenanceValidator> sort(List<ProvenanceValidator> validators) {
    switch (this) {
      case ValidatorSortingState.votingPower:
        validators.sort((a, b) => a.votingPower.compareTo(b.votingPower));
        break;
      case ValidatorSortingState.delegators:
        validators.sort((a, b) => a.delegators.compareTo(b.delegators));
        break;
      case ValidatorSortingState.commission:
        validators.sort((a, b) => a.rawCommission.compareTo(b.rawCommission));
        break;
      case ValidatorSortingState.alphabetically:
        return validators
          ..sort((a, b) =>
              a.moniker.toLowerCase().compareTo(b.moniker.toLowerCase()));
    }
    return validators.reversed.toList();
  }
}
