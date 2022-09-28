import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_color.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/services/validator_client/validator_client.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class StakingDetailsBloc extends Disposable implements StakingFlowNavigator {
  final StakingFlowNavigator _navigator;

  final _validatorDetails =
      BehaviorSubject.seeded(DetailedValidatorDetails(null, null, null, null));
  final _isLoading = BehaviorSubject.seeded(false);
  final String _validatorAddress;
  final TransactableAccount _account;
  final Delegation? _selectedDelegation;
  final Rewards? _rewards;
  final _validatorClient = get<ValidatorClient>();

  StakingDetailsBloc(
    this._validatorAddress,
    this._account,
    this._selectedDelegation,
    this._rewards, {
    required StakingFlowNavigator navigator,
  }) : _navigator = navigator;

  ValueStream<bool> get isLoading => _isLoading;
  ValueStream<DetailedValidatorDetails> get validatorDetails =>
      _validatorDetails;

  Future<void> load() async {
    _isLoading.tryAdd(true);
    final account = _account;

    try {
      final validator = await _validatorClient.getDetailedValidator(
        account.coin,
        _validatorAddress,
      );

      final commission = await _validatorClient.getValidatorCommission(
        account.coin,
        _validatorAddress,
      );

      _validatorDetails.tryAdd(DetailedValidatorDetails(
        validator,
        commission,
        _selectedDelegation,
        _rewards,
      ));
    } finally {
      _isLoading.tryAdd(false);
    }
  }

  @override
  FutureOr onDispose() {
    _isLoading.close();
    _validatorDetails.close();
  }

  PwColor getColor(ValidatorStatus status) {
    switch (status) {
      case ValidatorStatus.active:
        return PwColor.primaryP500;
      case ValidatorStatus.candidate:
        return PwColor.secondary2;
      case ValidatorStatus.jailed:
        return PwColor.error;
    }
  }

  String getProvUrl() {
    switch (_account.coin) {
      case Coin.testNet:
        return 'https://explorer.test.provenance.io/validator/$_validatorAddress';
      case Coin.mainNet:
        return 'https://explorer.provenance.io/validator/$_validatorAddress';
    }
  }

  @override
  void onComplete() {
    _navigator.onComplete();
  }

  @override
  Future<void> showClaimRewardsReview(
      DetailedValidator validator, Reward? reward) async {
    _navigator.showClaimRewardsReview(validator, reward);
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
  Future<void> showTransactionData(Object? data, String screenTitle) async {
    _navigator.showTransactionData(data, screenTitle);
  }

  @override
  Future<void> showTransactionComplete(
    Object? response,
    SelectedDelegationType selected,
  ) async {
    _navigator.showTransactionComplete(response, selected);
  }

  @override
  Future<void> showUndelegationReview() async {
    _navigator.showUndelegationReview();
  }

  @override
  Future<void> showUndelegationScreen(DetailedValidator validator) async {
    _navigator.showUndelegationScreen(validator);
  }

  @override
  Future<void> showRedelegationAmountScreen() async {
    _navigator.showRedelegationAmountScreen();
  }

  @override
  Future<void> redirectToRedelegation(DetailedValidator validator) async {
    _navigator.redirectToRedelegation(validator);
  }

  @override
  void backToDashboard() {
    _navigator.backToDashboard();
  }
}

class DetailedValidatorDetails {
  DetailedValidatorDetails(
    this.validator,
    this.commission,
    this.delegation,
    this.rewards,
  );

  final Delegation? delegation;
  final DetailedValidator? validator;
  final Commission? commission;
  final Rewards? rewards;
}
