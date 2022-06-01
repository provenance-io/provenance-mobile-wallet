import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_staking.dart' as staking;
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/commission.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class StakingModalBloc extends Disposable {
  final BehaviorSubject<StakingModalDetails> _stakingModalDetails;
  final _isLoading = BehaviorSubject.seeded(false);
  StakingModalBloc(
    final Delegation? delegation,
    final DetailedValidator validator,
    final Commission commission,
    this._validatorAddress,
    this._accountDetails,
    this._transactionHandler,
  ) : _stakingModalDetails = BehaviorSubject.seeded(
          StakingModalDetails(
            validator,
            commission,
            delegation,
            delegation != null
                ? SelectedModalType.initial
                : SelectedModalType.delegate,
          ),
        );

  final String _validatorAddress;
  final AccountDetails _accountDetails;
  final TransactionHandler _transactionHandler;
  ValueStream<bool> get isLoading => _isLoading;
  ValueStream<StakingModalDetails> get stakingModalDetails =>
      _stakingModalDetails;

  @override
  FutureOr onDispose() {
    _isLoading.close();
    _stakingModalDetails.close();
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

  void updateSelectedModal(SelectedModalType selected) {
    final oldDetails = _stakingModalDetails.value;
    _stakingModalDetails.tryAdd(
      StakingModalDetails(
        oldDetails.validator,
        oldDetails.commission,
        oldDetails.delegation,
        selected,
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

class StakingModalDetails {
  StakingModalDetails(
    this.validator,
    this.commission,
    this.delegation,
    this.selectedModalType,
  );

  final Delegation? delegation;
  final DetailedValidator validator;
  final Commission commission;
  final SelectedModalType selectedModalType;
}

enum SelectedModalType {
  initial,
  delegate,
  claimRewards,
  undelegate,
  redelegate,
}

extension SelectedModalTypeExtension on SelectedModalType {
  String get dropDownTitle {
    switch (this) {
      case SelectedModalType.initial:
        return "Back";
      case SelectedModalType.delegate:
      case SelectedModalType.redelegate:
      case SelectedModalType.undelegate:
        return name.capitalize();
      case SelectedModalType.claimRewards:
        return "Claim Rewards";
    }
  }
}
