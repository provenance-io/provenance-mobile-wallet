import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_distribution.dart';
import 'package:provenance_dart/proto_staking.dart' as staking;
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class StakingDelegationBloc extends Disposable {
  final BehaviorSubject<StakingDelegationDetails> _stakingDelegationDetails;
  StakingDelegationBloc(
    final Delegation? delegation,
    final DetailedValidator validator,
    final String commissionRate,
    final SelectedDelegationType selectedDelegationType,
    this._account,
  ) : _stakingDelegationDetails = BehaviorSubject.seeded(
          StakingDelegationDetails(
            validator,
            commissionRate,
            delegation,
            selectedDelegationType,
            null,
            0,
            _account,
          ),
        );

  final Account _account;
  ValueStream<StakingDelegationDetails> get stakingDelegationDetails =>
      _stakingDelegationDetails;

  @override
  FutureOr onDispose() {
    _stakingDelegationDetails.close();
  }

  Future<void> load() async {
    final asset = (await get<AssetService>()
            .getAssets(_account.publicKey!.coin, _account.publicKey!.address))
        .firstWhere((element) => element.denom == 'nhash');
    final oldDetails = _stakingDelegationDetails.value;
    _stakingDelegationDetails.tryAdd(
      StakingDelegationDetails(
        oldDetails.validator,
        oldDetails.commissionRate,
        oldDetails.delegation,
        oldDetails.selectedDelegationType,
        asset,
        oldDetails.hashDelegated,
        oldDetails.account,
      ),
    );
  }

  void updateHashDelegated(num hashDelegated) {
    final oldDetails = _stakingDelegationDetails.value;
    _stakingDelegationDetails.tryAdd(
      StakingDelegationDetails(
        oldDetails.validator,
        oldDetails.commissionRate,
        oldDetails.delegation,
        oldDetails.selectedDelegationType,
        oldDetails.asset,
        hashDelegated,
        oldDetails.account,
      ),
    );
  }

  Future<void> doDelegate(
    double? gasAdjustment,
  ) async {
    final details = _stakingDelegationDetails.value;

    await _sendMessage(
      gasAdjustment,
      staking.MsgDelegate(
        amount: proto.Coin(
          denom: details.asset?.denom ?? 'nhash',
          amount: details.hashDelegated.toString(),
        ),
        delegatorAddress: _account.publicKey!.address,
        validatorAddress: details.validator.operatorAddress,
      ).toAny(),
    );
  }

  Future<void> doUndelegate(
    double? gasAdjustment,
  ) async {
    final details = _stakingDelegationDetails.value;
    await _sendMessage(
      gasAdjustment,
      staking.MsgUndelegate(
        amount: proto.Coin(
          denom: details.asset?.denom ?? 'nhash',
          amount: details.hashDelegated.toString(),
        ),
        delegatorAddress: _account.publicKey!.address,
        validatorAddress: details.validator.operatorAddress,
      ).toAny(),
    );
  }

  Future<void> claimRewards(
    double? gasAdjustment,
  ) async {
    final details = _stakingDelegationDetails.value;
    await _sendMessage(
      gasAdjustment,
      MsgWithdrawDelegatorReward(
        delegatorAddress: _account.publicKey!.address,
        validatorAddress: details.validator.operatorAddress,
      ).toAny(),
    );
  }

  Future<void> _sendMessage(
    double? gasAdjustment,
    proto.Any message,
  ) async {
    final body = proto.TxBody(
      messages: [
        message,
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

class StakingDelegationDetails {
  StakingDelegationDetails(
    this.validator,
    this.commissionRate,
    this.delegation,
    this.selectedDelegationType,
    this.asset,
    this.hashDelegated,
    this.account,
  );

  final Delegation? delegation;
  final DetailedValidator validator;
  final String commissionRate;
  final SelectedDelegationType selectedDelegationType;
  final Asset? asset;
  final num hashDelegated;
  final Account account;

  bool get hashInsufficient {
    if (0 == hashDelegated) {
      return false;
    }
    final remainingHash =
        num.tryParse(asset?.amount.nhashToHash(fractionDigits: 7) ?? "");

    if (null == remainingHash) {
      return true;
    }

    return hashDelegated > remainingHash;
  }
}

enum SelectedDelegationType {
  initial,
  delegate,
  claimRewards,
  undelegate,
  redelegate,
}

extension SelectedDelegationTypeExtension on SelectedDelegationType {
  String get dropDownTitle {
    switch (this) {
      case SelectedDelegationType.initial:
        return Strings.stakingDelegationBlocBack;
      case SelectedDelegationType.delegate:
      case SelectedDelegationType.redelegate:
      case SelectedDelegationType.undelegate:
        return name.capitalize();
      case SelectedDelegationType.claimRewards:
        return Strings.stakingDelegationBlocClaimRewards;
    }
  }
}
