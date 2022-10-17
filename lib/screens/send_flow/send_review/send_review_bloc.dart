import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_cosmos_bank_v1beta1.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';

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
    this._txQueueService,
    this.receivingAddress,
    this.sendingAsset,
    this.fee,
    this.note,
    this._navigator,
  ) {
    final state = SendReviewBlocState(
      receivingAddress,
      sendingAsset,
      fee,
    );

    _stateStreamController.add(state);
  }

  final SendReviewNaviagor _navigator;
  final _stateStreamController = StreamController<SendReviewBlocState>();
  final TxQueueService _txQueueService;
  final TransactableAccount _accountDetails;
  final String receivingAddress;
  final String? note;
  final SendAsset sendingAsset;
  final MultiSendAsset fee;

  Stream<SendReviewBlocState> get stream => _stateStreamController.stream;

  @override
  FutureOr onDispose() {
    _stateStreamController.close();
  }

  Future<ScheduledTx> doSend() async {
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

    final response = await _txQueueService.scheduleTx(
      txBody: body,
      account: _accountDetails,
      gasEstimate: estimate,
    );

    return response;
  }

  Future<void> complete() async {
    _navigator.complete();
  }
}
