import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_staking.dart' as staking;
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

// FIXME: Not used/registered yet.
class StakingConfirmBloc extends Disposable {
  StakingConfirmBloc(
    this._validatorAddress,
    this._accountDetails,
    this._transactionHandler,
  );

  final String _validatorAddress;
  final AccountDetails _accountDetails;
  final TransactionHandler _transactionHandler;

  Future<void> doDelegate(
    num amount,
    double gasEstimate,
    String denom,
  ) async {
    await _sendMessage(
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

  Future<void> doUndelegate(
    num amount,
    double gasEstimate,
    String denom,
  ) async {
    await _sendMessage(
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

  @override
  FutureOr onDispose() {
    // TODO: Remove `Disposable` if not needing to implement this.
  }

  Future<void> _sendMessage(
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
