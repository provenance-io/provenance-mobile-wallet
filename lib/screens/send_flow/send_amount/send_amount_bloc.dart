import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class SendAmountBlocNavigator {
  Future<void> showReviewSend(String amountToSend, Decimal fee, String note,);
}

class SendAmountBlocState {
  SendAmountBlocState(this.transactionFees);

  final String? transactionFees;
}

class SendAmountBloc extends Disposable {
  SendAmountBloc(this.walletDetails, this.receivingAddress, this.asset, this._navigator,);

  final WalletDetails walletDetails;
  final _streamController = StreamController<SendAmountBlocState>();
  final SendAmountBlocNavigator _navigator;
  Decimal? _fee;

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

    get<WalletService>().estimate(body, walletDetails)
      .then((nhasGas) {
        _fee = Decimal.fromInt(nhasGas);
        final rationalFee = (_fee! / Decimal.fromInt(1000000000)).toDecimal(scaleOnInfinitePrecision: 9);
        final formattedFee = "${rationalFee.toString()} hash";
        final state = SendAmountBlocState(formattedFee);
        _streamController.add(state);
      });
  }

  String? validateAmount(String? proposedAmount) {
    proposedAmount ??= "";
    final val = Decimal.tryParse(proposedAmount);
    if(val == null) {
      return "'$proposedAmount' ${Strings.sendAmountErrorInvalidAmount}";
    }

    final decimalIndex = proposedAmount.indexOf('.');
    if(decimalIndex >= 0) {
      int decimalPlaces = proposedAmount.length - (decimalIndex + 1);
      if(decimalPlaces > 9) {
        return Strings.sendAmountErrorTooManyDecimalPlaces;
      }
    }

    if(Decimal.parse(asset.amount) < val) {
      return "${Strings.sendAmountErrorInsufficient} ${asset.denom}";
    }

    return null;
  }

  @override
  FutureOr onDispose() {
    _streamController.close();
  }

  Future<void> showNext(String note, String amount) {
    final amountError = validateAmount(amount);

    if(_fee == null) {
      return Future.error(Exception(Strings.sendAmountErrorGasEstimateNotReady));
    }

    if(amountError?.isNotEmpty ?? false) {
      return Future.error(Exception(amountError));
    }

    return this._navigator.showReviewSend(amount, _fee!, note,);
  }

}