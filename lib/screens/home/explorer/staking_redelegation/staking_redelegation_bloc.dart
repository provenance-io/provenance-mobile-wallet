import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_staking.dart' as staking;
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/util/extensions/num_extensions.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';

class StakingRedelegationBloc extends Disposable {
  StakingRedelegationBloc(
    final DetailedValidator validator,
    final Delegation delegation,
    this._account,
  ) : _stakingRedelegationDetails = BehaviorSubject.seeded(
          StakingRedelegationDetails(
            validator,
            delegation,
            0,
            _account,
            null,
          ),
        );

  final BehaviorSubject<StakingRedelegationDetails> _stakingRedelegationDetails;
  final _isLoading = BehaviorSubject.seeded(false);
  final Account _account;
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
      final oldDetails = _stakingRedelegationDetails.value;
      _stakingRedelegationDetails.tryAdd(
        StakingRedelegationDetails(
          oldDetails.validator,
          oldDetails.delegation,
          oldDetails.hashRedelegated,
          oldDetails.account,
          oldDetails.toRedelegate,
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
        oldDetails.validator,
        oldDetails.delegation,
        hashRedelegated,
        oldDetails.account,
        oldDetails.toRedelegate,
      ),
    );
  }

  void selectRedelegation(ProvenanceValidator? toRedelegate) {
    final oldDetails = _stakingRedelegationDetails.value;
    _stakingRedelegationDetails.tryAdd(
      StakingRedelegationDetails(
        oldDetails.validator,
        oldDetails.delegation,
        oldDetails.hashRedelegated,
        oldDetails.account,
        toRedelegate,
      ),
    );
  }

  Future<void> doRedelegate(
    double? gasAdjustment,
  ) async {
    final details = _stakingRedelegationDetails.value;

    final body = proto.TxBody(
      messages: [
        staking.MsgBeginRedelegate(
                amount: proto.Coin(
                  denom: 'nhash',
                  amount: details.hashRedelegated.nhashFromHash(),
                ),
                delegatorAddress: _account.publicKey!.address,
                validatorSrcAddress: details.delegation.sourceAddress,
                validatorDstAddress: details.toRedelegate?.addressId ?? "")
            .toAny(),
      ],
    );

    final privateKey = await get<AccountService>().loadKey(_account.id);
    final adjustedEstimate = await _estimateGas(body);

    AccountGasEstimate estimate = AccountGasEstimate(
      adjustedEstimate.estimate,
      adjustedEstimate.baseFee,
      gasAdjustment ?? adjustedEstimate.feeAdjustment,
      adjustedEstimate.feeCalculated,
    );

    final response = await get<TransactionHandler>().executeTransaction(
      body,
      privateKey!,
      estimate,
    );

    log(response.asJsonString());
  }

  Future<AccountGasEstimate> _estimateGas(proto.TxBody body) async {
    return await (get<TransactionHandler>())
        .estimateGas(body, _account.publicKey!);
  }
}

class StakingRedelegationDetails {
  StakingRedelegationDetails(
    this.validator,
    this.delegation,
    this.hashRedelegated,
    this.account,
    this.toRedelegate,
  );

  final DetailedValidator validator;
  final Delegation delegation;
  final SelectedDelegationType selectedDelegationType =
      SelectedDelegationType.redelegate;
  final num hashRedelegated;
  final Account account;
  final ProvenanceValidator? toRedelegate;
}
