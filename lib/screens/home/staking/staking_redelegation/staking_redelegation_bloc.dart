import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_cosmos_staking_v1beta1.dart' as staking;
import 'package:provenance_dart/type_registry.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/screens/home/staking/staking_delegation/staking_delegation_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/denom_util.dart';
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
            Decimal.zero,
            _account,
            null,
          ),
        );

  final BehaviorSubject<StakingRedelegationDetails> _stakingRedelegationDetails;
  final _isLoading = BehaviorSubject.seeded(false);
  final TransactableAccount _account;
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

  void updateHashRedelegated(Decimal hashRedelegated) {
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

  staking.MsgBeginRedelegate _getRedelegateMessage() {
    final details = _stakingRedelegationDetails.value;
    return staking.MsgBeginRedelegate(
        amount: proto.Coin(
          denom: nHashDenom,
          amount: hashToNHash(details.hashRedelegated).toString(),
        ),
        delegatorAddress: _account.address,
        validatorSrcAddress: details.delegation.sourceAddress,
        validatorDstAddress: details.toRedelegate?.addressId ?? "");
  }

  Object? getRedelegateMessageJson() {
    return _getRedelegateMessage().toProto3Json(typeRegistry: provenanceTypes);
  }

  Future<Object?> doRedelegate(
    double? gasAdjustment,
  ) async {
    final body = proto.TxBody(
      messages: [
        _getRedelegateMessage().toAny(),
      ],
    );

    final privateKey = await get<AccountService>().loadKey(_account.id);
    final adjustedEstimate = await _estimateGas(body);

    AccountGasEstimate estimate = AccountGasEstimate(
      adjustedEstimate.estimatedGas,
      adjustedEstimate.baseFee,
      gasAdjustment ?? adjustedEstimate.gasAdjustment,
      adjustedEstimate.totalFees,
    );

    final response = await get<TransactionHandler>().executeTransaction(
      body,
      privateKey.defaultKey(),
      _account.coin,
      estimate,
    );

    log(response.asJsonString());
    return response.txResponse.toProto3Json(typeRegistry: provenanceTypes);
  }

  Future<AccountGasEstimate> _estimateGas(proto.TxBody body) async {
    return await (get<TransactionHandler>()).estimateGas(
      body,
      [_account.publicKey],
      _account.coin,
    );
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
  final Decimal hashRedelegated;
  final Account account;
  final ProvenanceValidator? toRedelegate;
}
