import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_staking.dart' as staking;
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/abbreviated_validator.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/validator_service/validator_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
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

  Future<void> doRedelegate(
    double gasEstimate,
  ) async {
    final details = _stakingRedelegationDetails.value;

    final body = proto.TxBody(
      messages: [
        staking.MsgBeginRedelegate(
                amount: proto.Coin(
                  denom: 'nhash',
                  amount: details.hashRedelegated.toString(),
                ),
                delegatorAddress: _accountDetails.address,
                validatorDstAddress: details.delegation.address,
                validatorSrcAddress: details.toRedelegate?.address ?? "")
            .toAny(),
      ],
    );

    final privateKey = await get<AccountService>().loadKey(_accountDetails.id);
    final adjustedEstimate = int.parse(
        (Decimal.parse(gasEstimate.toString()) * Decimal.fromInt(10).pow(9))
            .toString());

    AccountGasEstimate estimate = AccountGasEstimate(
      adjustedEstimate,
      null,
      null,
      [],
    );

    final response = await get<TransactionHandler>().executeTransaction(
      body,
      privateKey!,
      estimate,
    );

    log(response.asJsonString());
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
