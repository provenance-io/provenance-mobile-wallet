import 'dart:async';

import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';

class StakingFlowBloc implements StakingFlowNavigator {
  final StakingFlowNavigator _navigator;

  StakingFlowBloc({
    required StakingFlowNavigator navigator,
  }) : _navigator = navigator;

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
