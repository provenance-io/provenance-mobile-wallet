import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_color.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/screens/home/explorer/explorer_bloc.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/validator_service/validator_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class StakingDetailsBloc extends Disposable {
  final _validatorDetails =
      BehaviorSubject.seeded(DetailedValidatorDetails(null, null));
  final _isLoading = BehaviorSubject.seeded(false);
  final String _validatorAddress;
  final AccountDetails _accountDetails;
  final _validatorService = get<ValidatorService>();

  StakingDetailsBloc(this._validatorAddress, this._accountDetails);

  ValueStream<bool> get isLoading => _isLoading;
  ValueStream<DetailedValidatorDetails> get validatorDetails =>
      _validatorDetails;

  Future<void> load() async {
    _isLoading.tryAdd(true);
    final account = _accountDetails;

    try {
      final validator = await _validatorService.getDetailedValidator(
        account.coin,
        _validatorAddress,
      );

      final commission = await _validatorService.getValidatorCommission(
        account.coin,
        _validatorAddress,
      );

      _validatorDetails.tryAdd(DetailedValidatorDetails(
        validator,
        commission,
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
        return PwColor.notice800;
      case ValidatorStatus.jailed:
        return PwColor.error;
    }
  }

  String getProvUrl() {
    switch (_accountDetails.coin) {
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
  );

  final DetailedValidator? validator;
  final Commission? commission;
}
