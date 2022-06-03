import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/services/models/abbreviated_validator.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/validator_service/validator_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class StakingRedelegationBloc extends Disposable {
  StakingRedelegationBloc(
    final Delegation delegation,
    this._accountDetails,
  ) : _stakingRedelegationDetails = BehaviorSubject.seeded(
          StakingRedelegationDetails(
            delegation,
            0,
            _accountDetails,
            null,
            [],
          ),
        );

  final BehaviorSubject<StakingRedelegationDetails> _stakingRedelegationDetails;
  final _isLoading = BehaviorSubject.seeded(false);
  final AccountDetails _accountDetails;
  ValueStream<bool> get isLoading => _isLoading;
  ValueStream<StakingRedelegationDetails> get stakingRedelegationDetails =>
      _stakingRedelegationDetails;

  @override
  FutureOr onDispose() {
    _isLoading.close();
    _stakingRedelegationDetails.close();
  }

  Future<void> load() async {
    _isLoading.tryAdd(true);
    try {
      final validators = await get<ValidatorService>()
          .getAbbreviatedValidators(_accountDetails.coin, 1);
      final oldDetails = _stakingRedelegationDetails.value;
      _stakingRedelegationDetails.tryAdd(
        StakingRedelegationDetails(
          oldDetails.delegation,
          oldDetails.hashRedelegated,
          oldDetails.accountDetails,
          oldDetails.toRedelegate,
          validators,
        ),
      );
    } finally {
      _isLoading.tryAdd(false);
    }
  }

  void updateHashRedelegated(num hashRedelegated) {
    final oldDetails = _stakingRedelegationDetails.value;
    _stakingRedelegationDetails.tryAdd(
      StakingRedelegationDetails(
        oldDetails.delegation,
        hashRedelegated,
        oldDetails.accountDetails,
        oldDetails.toRedelegate,
        oldDetails.validators,
      ),
    );
  }

  void selectRedelegation(AbbreviatedValidator toRedelegate) {
    final oldDetails = _stakingRedelegationDetails.value;
    _stakingRedelegationDetails.tryAdd(
      StakingRedelegationDetails(
        oldDetails.delegation,
        oldDetails.hashRedelegated,
        oldDetails.accountDetails,
        toRedelegate,
        oldDetails.validators,
      ),
    );
  }
}

class StakingRedelegationDetails {
  StakingRedelegationDetails(
    this.delegation,
    this.hashRedelegated,
    this.accountDetails,
    this.toRedelegate,
    this.validators,
  );

  final Delegation delegation;
  final SelectedDelegationType selectedDelegationType =
      SelectedDelegationType.redelegate;
  final num hashRedelegated;
  final AccountDetails accountDetails;
  final AbbreviatedValidator? toRedelegate;
  final List<AbbreviatedValidator> validators;
}
