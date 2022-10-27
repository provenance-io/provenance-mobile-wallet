import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_cosmos_bank_v1beta1.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/price_client/price_service.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/util/get.dart';

abstract class SendAmountBlocNavigator {
  Future<void> showReviewSend(
    SendAsset amountToSend,
    MultiSendAsset fee,
    String note,
  );
}

class SendAmountBlocState {
  SendAmountBlocState(this.transactionFees);

  final MultiSendAsset? transactionFees;
}

class SendAmountBloc extends Disposable {
  SendAmountBloc(
    this.account,
    this.receivingAddress,
    this.asset,
    this._priceClient,
    this._navigator, {
    required this.requiredString,
    required this.insufficientString,
    required this.tooManyDecimalPlacesString,
    required this.gasEstimateNotReadyString,
  });

  final _streamController = StreamController<SendAmountBlocState>();
  final SendAmountBlocNavigator _navigator;
  final PriceClient _priceClient;

  MultiSendAsset? _fee;

  final TransactableAccount account;
  final SendAsset asset;
  final String receivingAddress;
  final String requiredString;
  final String insufficientString;
  final String tooManyDecimalPlacesString;
  final String gasEstimateNotReadyString;

  Stream<SendAmountBlocState> get stream => _streamController.stream;

  Future<void> init() async {
    final body = TxBody(
      messages: [
        MsgSend(
          fromAddress: account.address,
          toAddress: receivingAddress,
          amount: [
            Coin(
              denom: asset.denom,
              amount: "1",
            ),
          ],
        ).toAny(),
      ],
    );

    final coin = account.coin;

    final estimate = await get<TxQueueService>().estimateGas(
      account: account,
      txBody: body,
    );

    List<SendAsset> individualFees = <SendAsset>[];

    final denoms = estimate.totalFees.map((e) => e.denom).toList();
    final priceLookup = await _priceClient.getAssetPrices(coin, denoms).then(
          (prices) => {for (var price in prices) price.denomination: price},
        );

    for (var fee in estimate.totalFees) {
      final price = priceLookup[fee.denom]?.usdPrice ?? 0;
      final sendAsset = SendAsset(
        fee.denom,
        1,
        fee.denom,
        Decimal.parse(fee.amount),
        price,
      );
      individualFees.add(sendAsset);
    }

    _fee = MultiSendAsset(
      estimate.estimatedGas,
      individualFees,
    );

    final state = SendAmountBlocState(_fee);
    _streamController.tryAdd(state);
  }

  String? validateAmount(String? proposedAmount) {
    proposedAmount ??= "";
    final val = Decimal.tryParse(proposedAmount);
    if (val == null) {
      return requiredString;
    }

    final scaledValue = (val * Decimal.fromInt(10).pow(asset.exponent));

    if (asset.amount < scaledValue) {
      return "$insufficientString ${asset.displayDenom}";
    }

    final dotIndex = proposedAmount.indexOf(".");
    if (dotIndex >= 0) {
      final decimalDigits = (proposedAmount.length - dotIndex - 1);
      if (decimalDigits > asset.exponent) {
        return tooManyDecimalPlacesString;
      }
    }

    return null;
  }

  @override
  FutureOr onDispose() {
    _streamController.close();
  }

  Future<void> showNext(String note, String amount) {
    if (_fee == null) {
      return Future.error(Exception(
        gasEstimateNotReadyString,
      ));
    }

    final amountError = validateAmount(amount);

    if (amountError?.isNotEmpty ?? false) {
      return Future.error(Exception(amountError));
    }

    final val = Decimal.parse(amount);
    final scaledValue = (val * Decimal.fromInt(10).pow(asset.exponent));

    final sendingAsset = SendAsset(
      asset.displayDenom,
      asset.exponent,
      asset.denom,
      scaledValue,
      asset.fiatValue,
    );

    return _navigator.showReviewSend(
      sendingAsset,
      _fee!,
      note,
    );
  }
}
