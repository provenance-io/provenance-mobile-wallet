import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/services/validator_service/validator_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class ExplorerBloc extends Disposable {
  final _isLoadingValidators = BehaviorSubject.seeded(false);
  final _isLoadingDelegations = BehaviorSubject.seeded(false);
  final _stakingDetails = BehaviorSubject.seeded(
    StakingDetails(
      address: "",
      delegates: [],
      validators: [],
    ),
  );
  final _validatorPages = BehaviorSubject.seeded(1);
  final _delegationPages = BehaviorSubject.seeded(1);
  final _validatorService = get<ValidatorService>();
  final AccountDetails _accountDetails;

  ExplorerBloc({
    required AccountDetails accountDetails,
  }) : _accountDetails = accountDetails;

  ValueStream<StakingDetails> get stakingDetails => _stakingDetails;
  ValueStream<bool> get isLoadingValidators => _isLoadingValidators;
  ValueStream<bool> get isLoadingDelegations => _isLoadingDelegations;

  @override
  FutureOr onDispose() {
    _isLoadingValidators.close();
    _stakingDetails.close();
    _validatorPages.close();
  }

  Future<void> updateState(DelegationState state) async {
    final oldDetails = _stakingDetails.value;

    if (state == oldDetails.selectedState) {
      return;
    }

    _delegationPages.value = 1;

    final delegations = await _validatorService.getDelegations(
        _accountDetails.coin,
        _accountDetails.address,
        _delegationPages.value,
        state);

    _stakingDetails.tryAdd(
      StakingDetails(
        delegates: delegations,
        validators: oldDetails.validators,
        address: oldDetails.address,
        selectedState: state,
        selectedStatus: oldDetails.selectedStatus,
      ),
    );
  }

  Future<List<T>> _loadMore<T>(
      List<T> oldList,
      BehaviorSubject<int> pages,
      BehaviorSubject<bool> isLoading,
      Future<List<T>> Function() function) async {
    if (pages.value * 30 > oldList.length) {
      return oldList;
    }
    pages.value++;
    isLoading.value = true;
    final newList = await function();

    if (newList.isNotEmpty) {
      oldList.addAll(newList);
    }
    return oldList;
  }

  Future<void> loadAdditionalDelegates() async {
    var oldDetails = _stakingDetails.value;

    final delegates = await _loadMore(
        oldDetails.delegates,
        _delegationPages,
        _isLoadingDelegations,
        () async => await _validatorService.getDelegations(
            _accountDetails.coin,
            _accountDetails.address,
            _delegationPages.value,
            oldDetails.selectedState));

    _stakingDetails.tryAdd(
      StakingDetails(
        delegates: delegates,
        validators: oldDetails.validators,
        address: oldDetails.address,
        selectedState: oldDetails.selectedState,
        selectedStatus: oldDetails.selectedStatus,
      ),
    );

    _isLoadingValidators.value = false;
  }

  Future<void> loadAdditionalValidators() async {
    var oldDetails = _stakingDetails.value;

    final validators = await _loadMore(
        oldDetails.validators,
        _validatorPages,
        _isLoadingValidators,
        () async => await _validatorService.getRecentValidators(
              _accountDetails.coin,
              _validatorPages.value,
              oldDetails.selectedStatus,
            ));

    _stakingDetails.tryAdd(
      StakingDetails(
        delegates: oldDetails.delegates,
        validators: validators,
        address: oldDetails.address,
        selectedState: oldDetails.selectedState,
        selectedStatus: oldDetails.selectedStatus,
      ),
    );

    _isLoadingValidators.value = false;
  }
}

class StakingDetails {
  StakingDetails({
    required this.delegates,
    required this.validators,
    this.selectedState = DelegationState.bonded,
    this.selectedStatus = ValidatorStatus.active,
    required this.address,
  });

// FIXME: delegates are a different type eventually
  final List<Delegation> delegates;
  final List<ProvenanceValidator> validators;
  final DelegationState selectedState;
  final ValidatorStatus selectedStatus;
  final String address;
}

enum DelegationState {
  bonded,
  redelegated,
  unbonded,
}

enum ValidatorStatus {
  active,
  candidate,
  jailed,
}

extension ValidatorStatusExtension on ValidatorStatus {
  String get dropDownTitle {
    switch (this) {
      case ValidatorStatus.active:
        return Strings.dropDownActive;
      case ValidatorStatus.candidate:
        return Strings.dropDownCandidate;
      case ValidatorStatus.jailed:
        return Strings.dropDownJailed;
    }
  }
}

extension DelegationStateExtension on DelegationState {
  String get dropDownTitle {
    switch (this) {
      case DelegationState.bonded:
        return Strings.dropDownDelegate;
      case DelegationState.redelegated:
        return Strings.dropDownRedelegate;
      case DelegationState.unbonded:
        return Strings.dropDownUndelegate;
    }
  }

  String get urlRoute {
    switch (this) {
      case DelegationState.bonded:
        return 'delegations';
      case DelegationState.redelegated:
        return 'redelegations';
      case DelegationState.unbonded:
        return 'unbonding';
    }
  }
}
