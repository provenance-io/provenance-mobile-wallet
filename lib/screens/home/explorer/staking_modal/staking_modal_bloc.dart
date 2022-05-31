import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_staking.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

abstract class StakingModalNavigator {}

class StakingModalBloc extends Disposable {
  StakingModalBloc(
    this._validatorAddress,
    this._navigator,
    this._accountDetails,
    this._transactionHandler,
  );

  final String _validatorAddress;
  final StakingModalNavigator _navigator;
  final AccountDetails _accountDetails;
  final TransactionHandler _transactionHandler;

  @override
  FutureOr onDispose() {
    // TODO: implement onDispose
    throw UnimplementedError();
  }

  Future<void> doDelegate(num amount, double gasEstimate, String denom) async {
    await _sendMessage(
      amount,
      gasEstimate,
      denom,
      MsgDelegate(
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
      amount,
      gasEstimate,
      denom,
      MsgUndelegate(
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
      MsgBeginRedelegate(
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
