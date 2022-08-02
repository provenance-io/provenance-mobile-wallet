import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/price_service/price_service.dart';
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
    this.accountDetails,
    this.receivingAddress,
    this.asset,
    this._priceService,
    this._navigator, {
    required this.requiredString,
    required this.insufficientString,
    required this.tooManyDecimalPlacesString,
    required this.gasEstimateNotReadyString,
  });

  final _streamController = StreamController<SendAmountBlocState>();
  final SendAmountBlocNavigator _navigator;
  final PriceService _priceService;

  MultiSendAsset? _fee;

  final Account accountDetails;
  final SendAsset asset;
  final String receivingAddress;
  final String requiredString;
  final String insufficientString;
  final String tooManyDecimalPlacesString;
  final String gasEstimateNotReadyString;

  Stream<SendAmountBlocState> get stream => _streamController.stream;

  void init() {
    final body = TxBody(
      messages: [
        MsgSend(
          fromAddress: accountDetails.publicKey!.address,
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

    final publicKey = accountDetails.publicKey!;

    get<TransactionHandler>()
        .estimateGas(body, publicKey)
        .then((estimate) async {
      List<SendAsset> individualFees = <SendAsset>[];
      if (estimate.feeCalculated?.isNotEmpty ?? false) {
        final denoms = estimate.feeCalculated!.map((e) => e.denom).toList();
        final priceLookup =
            await _priceService.getAssetPrices(publicKey.coin, denoms).then(
                  (prices) =>
                      {for (var price in prices) price.denomination: price},
                );

        for (var fee in estimate.feeCalculated!) {
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
      }

      _fee = MultiSendAsset(
        estimate.estimate,
        individualFees,
      );

      final state = SendAmountBlocState(_fee);
      _streamController.add(state);
    });
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
