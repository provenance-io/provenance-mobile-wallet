import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_color.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/services/validator_service/validator_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class StakingDetailsBloc extends Disposable {
  final _validatorDetails =
      BehaviorSubject.seeded(DetailedValidatorDetails(null, null, null, null));
  final _isLoading = BehaviorSubject.seeded(false);
  final String _validatorAddress;
  final Account _account;
  final Delegation? _selectedDelegation;
  final Rewards? _rewards;
  final _validatorService = get<ValidatorService>();

  StakingDetailsBloc(
    this._validatorAddress,
    this._account,
    this._selectedDelegation,
    this._rewards,
  );

  ValueStream<bool> get isLoading => _isLoading;
  ValueStream<DetailedValidatorDetails> get validatorDetails =>
      _validatorDetails;

  Future<void> load() async {
    _isLoading.tryAdd(true);
    final account = _account;

    try {
      final validator = await _validatorService.getDetailedValidator(
        account.publicKey!.coin,
        _validatorAddress,
      );

      final commission = await _validatorService.getValidatorCommission(
        account.publicKey!.coin,
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
    switch (_account.publicKey!.coin) {
      case Coin.testNet:
        return 'https://explorer.test.provenance.io/validator/$_validatorAddress';
      case Coin.mainNet:
        return 'https://explorer.provenance.io/validator/$_validatorAddress';
    }
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
