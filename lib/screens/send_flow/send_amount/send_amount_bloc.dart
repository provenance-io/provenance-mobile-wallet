import 'dart:async';

import 'package:convert/convert.dart' as convert;
import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_dart/wallet.dart' as wallet;
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/price_service/price_service.dart';
import 'package:provenance_wallet/services/wallet_service/transaction_handler.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

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
    this.walletDetails,
    this.receivingAddress,
    this.asset,
    this._priceService,
    this._navigator,
  );

  final _streamController = StreamController<SendAmountBlocState>();
  final SendAmountBlocNavigator _navigator;
  final PriceService _priceService;

  MultiSendAsset? _fee;

  final WalletDetails walletDetails;
  final SendAsset asset;
  final String receivingAddress;

  Stream<SendAmountBlocState> get stream => _streamController.stream;

  void init() {
    final body = TxBody(
      messages: [
        MsgSend(
          fromAddress: walletDetails.address,
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

    final publicKey = wallet.PublicKey.fromCompressPublicHex(
      convert.hex.decoder.convert(walletDetails.publicKey),
      walletDetails.coin,
    );

    get<TransactionHandler>()
        .estimateGas(body, publicKey)
        .then((estimate) async {
      List<SendAsset> individualFees = <SendAsset>[];
      if (estimate.feeCalculated?.isNotEmpty ?? false) {
        final denoms = estimate.feeCalculated!.map((e) => e.denom).toList();
        final priceLookup =
            await _priceService.getAssetPrices(walletDetails.coin, denoms).then(
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
            "",
          );
          individualFees.add(sendAsset);
        }
      }

      final priceList =
          await _priceService.getAssetPrices(walletDetails.coin, ["nhash"]);
      final price = (priceList.isNotEmpty) ? priceList.first.usdPrice : 0.0;

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
      return Strings.required;
    }

    final scaledValue = (val * Decimal.fromInt(10).pow(asset.exponent));

    if (asset.amount < scaledValue) {
      return "${Strings.sendAmountErrorInsufficient} ${asset.displayDenom}";
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
        Strings.sendAmountErrorGasEstimateNotReady,
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
      asset.imageUrl,
    );

    return _navigator.showReviewSend(
      sendingAsset,
      _fee!,
      note,
    );
  }
}
