import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_transaction_handler.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
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

    for (var fee in fee.fees) {
      var current = map[fee.denom];
      if (current == null) {
        map[fee.denom] = fee;
      } else {
        map[fee.denom] = current.copyWith(amount: fee.amount + current.amount);
      }
    }

    return map.values.map((e) => e.displayAmount).join(" + ");
  }
}

class SendReviewBloc implements Disposable {
  SendReviewBloc(
    this._walletDetails,
    this._walletService,
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
  final WalletConnectTransactionHandler _walletService;
  final WalletDetails _walletDetails;
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
          fromAddress: _walletDetails.address,
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

    final privateKey = await get<WalletService>().loadKey(_walletDetails.id);

    GasEstimate estimate = GasEstimate(
      fee.limit.amount.toBigInt().toInt(),
      null,
      fee.fees
          .map((e) => Coin(
                denom: e.denom,
                amount: e.amount.toString(),
              ))
          .toList(),
    );

    return _walletService
        .executeTransaction(
          body,
          privateKey!,
          estimate,
        )
        .then((_) => null);
  }

  Future<void> complete() async {
    _naviagor.complete();
  }
}
