import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_staking.dart' as staking;
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class StakingDelegationBloc extends Disposable {
  final BehaviorSubject<StakingDelegationDetails> _stakingDelegationDetails;
  final _isLoading = BehaviorSubject.seeded(false);
  StakingDelegationBloc(
    final Delegation? delegation,
    final DetailedValidator validator,
    final Commission commission,
    this._validatorAddress,
    this._accountDetails,
    this._transactionHandler,
  ) : _stakingDelegationDetails = BehaviorSubject.seeded(
          StakingDelegationDetails(
            validator,
            commission,
            delegation,
            delegation != null
                ? SelectedDelegationType.initial
                : SelectedDelegationType.delegate,
            null,
            0,
            _accountDetails,
          ),
        );

  final String _validatorAddress;
  final AccountDetails _accountDetails;
  final TransactionHandler _transactionHandler;
  ValueStream<bool> get isLoading => _isLoading;
  ValueStream<StakingDelegationDetails> get stakingDelegationDetails =>
      _stakingDelegationDetails;

  @override
  FutureOr onDispose() {
    _isLoading.close();
    _stakingDelegationDetails.close();
  }

  Future<void> load() async {
    _isLoading.tryAdd(true);
    try {
      final asset = (await get<AssetService>()
              .getAssets(_accountDetails.coin, _accountDetails.address))
          .firstWhere((element) => element.denom == 'nhash');
      final oldDetails = _stakingDelegationDetails.value;
      _stakingDelegationDetails.tryAdd(
        StakingDelegationDetails(
          oldDetails.validator,
          oldDetails.commission,
          oldDetails.delegation,
          oldDetails.selectedModalType,
          asset,
          oldDetails.hashDelegated,
          oldDetails.accountDetails,
        ),
      );
    } finally {
      _isLoading.tryAdd(false);
    }
  }

  Future<void> doDelegate(
    num amount,
    double gasEstimate,
    String denom,
  ) async {
    await _sendMessage(
      amount,
      gasEstimate,
      denom,
      staking.MsgDelegate(
        amount: proto.Coin(
          denom: denom,
          amount: amount.toString(),
        ),
        delegatorAddress: _accountDetails.address,
        validatorAddress: _validatorAddress,
      ).toAny(),
    );
  }

  void updateSelectedModal(SelectedDelegationType selected) {
    final oldDetails = _stakingDelegationDetails.value;
    _stakingDelegationDetails.tryAdd(
      StakingDelegationDetails(
        oldDetails.validator,
        oldDetails.commission,
        oldDetails.delegation,
        selected,
        oldDetails.asset,
        oldDetails.hashDelegated,
        oldDetails.accountDetails,
      ),
    );
  }

  void updateHashDelegated(num hashDelegated) {
    final oldDetails = _stakingDelegationDetails.value;
    _stakingDelegationDetails.tryAdd(
      StakingDelegationDetails(
        oldDetails.validator,
        oldDetails.commission,
        oldDetails.delegation,
        oldDetails.selectedModalType,
        oldDetails.asset,
        hashDelegated,
        oldDetails.accountDetails,
      ),
    );
  }

  Future<void> doUndelegate(
    num amount,
    double gasEstimate,
    String denom,
  ) async {
    await _sendMessage(
      amount,
      gasEstimate,
      denom,
      staking.MsgUndelegate(
        amount: proto.Coin(
          denom: denom,
          amount: amount.toString(),
        ),
        delegatorAddress: _accountDetails.address,
        validatorAddress: _validatorAddress,
      ).toAny(),
    );
  }

  Future<void> doRedelegate(
    num amount,
    double gasEstimate,
    String denom,
    String destinationAddress,
  ) async {
    await _sendMessage(
      amount,
      gasEstimate,
      denom,
      staking.MsgBeginRedelegate(
              amount: proto.Coin(
                denom: denom,
                amount: amount.toString(),
              ),
              delegatorAddress: _accountDetails.address,
              validatorDstAddress: destinationAddress,
              validatorSrcAddress: _validatorAddress)
          .toAny(),
    );
  }

  Future<void> _sendMessage(
    num amount,
    double gasEstimate,
    String denom,
    proto.Any message,
  ) async {
    final body = proto.TxBody(
      messages: [
        message,
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

    final response = await _transactionHandler.executeTransaction(
      body,
      privateKey!,
      estimate,
    );

    log(response.asJsonString());
  }
}

class StakingDelegationDetails {
  StakingDelegationDetails(
    this.validator,
    this.commissionRate,
    this.delegation,
    this.selectedModalType,
    this.asset,
    this.hashDelegated,
    this.accountDetails,
  );

  final Delegation? delegation;
  final DetailedValidator validator;
  final String commissionRate;
  final SelectedDelegationType selectedModalType;
  final Asset? asset;
  final num hashDelegated;
  final AccountDetails accountDetails;

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

extension SelectedModalTypeExtension on SelectedDelegationType {
  String get dropDownTitle {
    switch (this) {
      case SelectedDelegationType.initial:
        return "Back";
      case SelectedDelegationType.delegate:
      case SelectedDelegationType.redelegate:
      case SelectedDelegationType.undelegate:
        return name.capitalize();
      case SelectedDelegationType.claimRewards:
        return "Claim Rewards";
    }
  }
}
