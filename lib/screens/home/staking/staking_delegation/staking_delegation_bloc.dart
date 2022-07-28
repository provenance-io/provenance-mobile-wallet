import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_distribution.dart';
import 'package:provenance_dart/proto_staking.dart' as staking;
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/denom_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class StakingDelegationBloc extends Disposable {
  final BehaviorSubject<StakingDelegationDetails> _stakingDelegationDetails;
  StakingDelegationBloc({
    Delegation? delegation,
    Reward? reward,
    required final DetailedValidator validator,
    final String commissionRate = "",
    required final SelectedDelegationType selectedDelegationType,
    required Account account,
  })  : _account = account,
        _stakingDelegationDetails = BehaviorSubject.seeded(
          StakingDelegationDetails(
            validator,
            commissionRate,
            delegation,
            selectedDelegationType,
            null,
            Decimal.zero,
            account,
            reward,
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
        oldDetails.reward,
      ),
    );
  }

  void updateHashDelegated(Decimal hashDelegated) {
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
        oldDetails.reward,
      ),
    );
  }

  Future<String> doDelegate(
    double? gasAdjustment,
  ) async {
    return await _sendMessage(
      gasAdjustment,
      _getDelegateMessage().toAny(),
    );
  }

  Future<String> doUndelegate(
    double? gasAdjustment,
  ) async {
    return await _sendMessage(
      gasAdjustment,
      _getUndelegateMessage().toAny(),
    );
  }

  Future<String> claimRewards(
    double? gasAdjustment,
  ) async {
    return await _sendMessage(
      gasAdjustment,
      _getClaimRewardMessage().toAny(),
    );
  }

  staking.MsgDelegate _getDelegateMessage() {
    final details = _stakingDelegationDetails.value;
    return staking.MsgDelegate(
      amount: proto.Coin(
        denom: details.asset?.denom ?? nHashDenom,
        amount: hashToNHash(details.hashDelegated).toString(),
      ),
      delegatorAddress: _account.publicKey!.address,
      validatorAddress: details.validator.operatorAddress,
    );
  }

  staking.MsgUndelegate _getUndelegateMessage() {
    final details = _stakingDelegationDetails.value;
    return staking.MsgUndelegate(
      amount: proto.Coin(
        denom: details.asset?.denom ?? nHashDenom,
        amount: hashToNHash(details.hashDelegated).toString(),
      ),
      delegatorAddress: _account.publicKey!.address,
      validatorAddress: details.validator.operatorAddress,
    );
  }

  MsgWithdrawDelegatorReward _getClaimRewardMessage() {
    final details = _stakingDelegationDetails.value;
    return MsgWithdrawDelegatorReward(
      delegatorAddress: _account.publicKey!.address,
      validatorAddress: details.validator.operatorAddress,
    );
  }

  Object? getClaimRewardJson() {
    return _getClaimRewardMessage().toProto3Json();
  }

  Object? getUndelegateMessageJson() {
    return _getUndelegateMessage().toProto3Json();
  }

  Object? getDelegateMessageJson() {
    return _getDelegateMessage().toProto3Json();
  }

  Future<String> _sendMessage(
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

    final stringifiedResponse = response.asJsonString();
    log(stringifiedResponse);
    return stringifiedResponse;
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
    this.reward,
  );

  final Delegation? delegation;
  final DetailedValidator validator;
  final String commissionRate;
  final SelectedDelegationType selectedDelegationType;
  final Asset? asset;
  final Decimal hashDelegated;
  final Account account;
  final Reward? reward;

  bool get hashInsufficient {
    if (Decimal.zero == hashDelegated) {
      return false;
    }

    final remainingHash = Decimal.parse(asset?.amount ?? '0');

    return hashDelegated > remainingHash;
  }

  String get hashFormatted {
    return hashDelegated.toString();
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
  String getDropDownTitle(BuildContext context) {
    switch (this) {
      case SelectedDelegationType.initial:
        return Strings.of(context).stakingDelegationBlocBack;
      case SelectedDelegationType.delegate:
        return Strings.of(context).menuDelegate;
      case SelectedDelegationType.redelegate:
        return Strings.of(context).menuRedelegate;
      case SelectedDelegationType.undelegate:
        return Strings.of(context).menuUndelegate;
      case SelectedDelegationType.claimRewards:
        return Strings.of(context).stakingDelegationBlocClaimRewards;
    }
  }

  String getCompletionMessage(BuildContext context) {
    // There is no way programmatically to get here with the 'initial' type.
    assert(this != SelectedDelegationType.initial);
    final strings = Strings.of(context);
    switch (this) {
      case SelectedDelegationType.initial:
        return "";
      case SelectedDelegationType.delegate:
        return strings.stakingCompleteDelegationComplete;
      case SelectedDelegationType.redelegate:
        return strings.stakingCompleteRedelegationComplete;
      case SelectedDelegationType.undelegate:
        return strings.stakingCompleteUndelegationComplete;
      case SelectedDelegationType.claimRewards:
        return strings.stakingCompleteClaimRewardsComplete;
    }
  }
}
