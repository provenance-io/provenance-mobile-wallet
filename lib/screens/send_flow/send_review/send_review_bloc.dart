import 'dart:async';
import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/util/get.dart';

abstract class SendReviewNaviagor {
  void complete();
}

class SendReviewBlocState {
  SendReviewBlocState(
    this.receivingAddress,
    this.sendingAsset,
    this.fee,
  );

  final String receivingAddress;
  final SendAsset sendingAsset;
  final MultiSendAsset fee;

  String get total {
    final map = <String, SendAsset>{};
    map[sendingAsset.denom] = sendingAsset;
    final fees = [...fee.fees];

    for (var fee in fees) {
      var current = map[fee.denom];
      if (current == null) {
        map[fee.denom] = fee;
      } else {
        var value = current.amount + fee.amount;
        map[fee.denom] = current.copyWith(amount: value);
      }
    }

    return map.entries
        .map((entry) =>
            "${entry.value.displayAmount} ${entry.value.displayDenom}")
        .join(" + \n");
  }
}

class SendReviewBloc implements Disposable {
  SendReviewBloc(
    this._accountDetails,
    this._transactionHandler,
    this.receivingAddress,
    this.sendingAsset,
    this.fee,
    this.note,
    this._naviagor,
  ) {
    final state = SendReviewBlocState(
      receivingAddress,
      sendingAsset,
      fee,
    );

    _stateStreamController.add(state);
  }

  final SendReviewNaviagor _naviagor;
  final _stateStreamController = StreamController<SendReviewBlocState>();
  final TransactionHandler _transactionHandler;
  final AccountDetails _accountDetails;
  final String receivingAddress;
  final String? note;
  final SendAsset sendingAsset;
  final MultiSendAsset fee;

  Stream<SendReviewBlocState> get stream => _stateStreamController.stream;

  @override
  FutureOr onDispose() {
    _stateStreamController.close();
  }

  Future<void> doSend() async {
    final amountToSend = sendingAsset.amount;

    final body = TxBody(
      memo: note,
      messages: [
        MsgSend(
          fromAddress: _accountDetails.address,
          toAddress: receivingAddress,
          amount: [
            Coin(
              denom: sendingAsset.denom,
              amount: amountToSend.toString(),
            ),
          ],
        ).toAny(),
      ],
    );

    final privateKey = await get<AccountService>().loadKey(_accountDetails.id);

    AccountGasEstimate estimate = AccountGasEstimate(
      fee.estimate,
      null,
      null,
      fee.fees
          .map((e) => Coin(
                denom: e.denom,
                amount: e.amount.toString(),
              ))
          .toList(),
    );

    final response = await _transactionHandler.executeTransaction(
      body,
      privateKey!,
      estimate,
    );

    log(response.asJsonString());
  }

  Future<void> complete() async {
    _naviagor.complete();
  }
}
