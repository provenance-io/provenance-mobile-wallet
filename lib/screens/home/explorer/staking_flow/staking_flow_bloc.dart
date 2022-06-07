import 'dart:async';

import 'package:provenance_wallet/common/classes/pw_paging_cache.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/models/abbreviated_validator.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/services/validator_service/validator_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class StakingFlowBloc extends PwPagingCache {
  final _isLoading = BehaviorSubject.seeded(false);
  final _isLoadingValidators = BehaviorSubject.seeded(false);
  final _isLoadingDelegations = BehaviorSubject.seeded(false);
  final _stakingDetails = BehaviorSubject.seeded(
    StakingDetails(
      abbreviatedValidators: [],
      address: "",
      delegates: [],
      validators: [],
    ),
  );
  final List<AbbreviatedValidator> _abbreviatedValidators = [];
  final _validatorPages = BehaviorSubject.seeded(1);
  final _delegationPages = BehaviorSubject.seeded(1);
  final _validatorService = get<ValidatorService>();
  final AccountDetails _accountDetails;

  StakingFlowBloc({
    required AccountDetails accountDetails,
  })  : _accountDetails = accountDetails,
        super(30);

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
      final account = _accountDetails;

      var abbrValidators = <AbbreviatedValidator>[];

      abbrValidators = await _validatorService.getAbbreviatedValidators(
        account.coin,
        1,
      );

      _abbreviatedValidators.addAll(abbrValidators);

      final delegations = await _validatorService.getDelegations(
        _accountDetails.coin,
        _accountDetails.address,
        _delegationPages.value,
      );

      final validators = await _validatorService.getRecentValidators(
        _accountDetails.coin,
        _validatorPages.value,
      );

      _stakingDetails.tryAdd(
        StakingDetails(
          abbreviatedValidators: _abbreviatedValidators,
          delegates: delegations,
          validators: validators,
          address: account.address,
        ),
      );
    } finally {
      if (showLoading) {
        _isLoading.tryAdd(false);
      }
    }
  }

  Future<void> updateState(DelegationState state) async {
    final oldDetails = _stakingDetails.value;

    if (state == oldDetails.selectedState) {
      return;
    }

    _isLoading.tryAdd(true);

    _delegationPages.value = 1;
    try {
      _stakingDetails.tryAdd(
        StakingDetails(
          abbreviatedValidators: _abbreviatedValidators,
          delegates: oldDetails.delegates,
          validators: validators,
          address: oldDetails.address,
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
        () async => await _validatorService.getDelegations(_accountDetails.coin,
            _accountDetails.address, _delegationPages.value));

    _stakingDetails.tryAdd(
      StakingDetails(
        abbreviatedValidators: _abbreviatedValidators,
        delegates: delegates,
        validators: oldDetails.validators,
        address: oldDetails.address,
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
              _accountDetails.coin,
              _validatorPages.value,
            ));

    _stakingDetails.tryAdd(
      StakingDetails(
        abbreviatedValidators: _abbreviatedValidators,
        delegates: oldDetails.delegates,
        validators: validators,
        address: oldDetails.address,
      ),
    );

    _isLoadingValidators.value = false;
  }
}

class StakingDetails {
  StakingDetails({
    required this.abbreviatedValidators,
    required this.delegates,
    required this.validators,
    required this.address,
  });

  final List<AbbreviatedValidator> abbreviatedValidators;
  final List<Delegation> delegates;
  final List<ProvenanceValidator> validators;
  final String address;
}

}

enum ValidatorStatus {
  active,
  candidate,
  jailed,
}

  String get dropDownTitle {
    switch (this) {
    }
  }

    switch (this) {
    }
  }
}
