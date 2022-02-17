import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class SendAmountBlocNavigator {
  Future<void> showReviewSend(String amountToSend, String fee, String note);
}

class SendAmountBlocState {
  SendAmountBlocState(this.transactionFees);

  final String? transactionFees;
}

class SendAmountBloc extends Disposable {
  SendAmountBloc(this.receivingAddress, this.asset, this._navigator);

  final _streamController = StreamController<SendAmountBlocState>();
  final SendAmountBlocNavigator _navigator;
  String? _fee;

  final SendAsset asset;
  final String receivingAddress;

  Stream<SendAmountBlocState> get stream => _streamController.stream;

  void init() {
    Future.delayed(
        Duration(milliseconds: 600),
        () {
          _fee = "0.02 Hash";
          final state = SendAmountBlocState(_fee);
          _streamController.add(state);
        },
    );
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

    return this._navigator.showReviewSend(amount, _fee!, note);
  }

}