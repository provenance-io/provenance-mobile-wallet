import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
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
    this._navigator,
  );

  final WalletDetails walletDetails;
  final _streamController = StreamController<SendAmountBlocState>();
  final SendAmountBlocNavigator _navigator;
  MultiSendAsset? _fee;

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

    get<WalletService>().estimate(body, walletDetails).then((estimate) async {
      List<SendAsset> individualFees = <SendAsset>[];
      if (estimate.feeCalculated?.isNotEmpty ?? false) {
        estimate.feeCalculated!.forEach((fee) {
          final sendAsset = SendAsset(
            fee.denom,
            1,
            fee.denom,
            Decimal.parse(fee.amount),
            "",
            "",
          );
          individualFees.add(sendAsset);
        });
      }

      _fee = MultiSendAsset(
        SendAsset(
          "hash",
          9,
          "nhash",
          Decimal.fromInt(estimate.limit),
          "",
          "",
        ),
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
      return "'$proposedAmount' ${Strings.sendAmountErrorInvalidAmount}";
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
      return Future.error(
          Exception(Strings.sendAmountErrorGasEstimateNotReady));
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
      "",
      asset.imageUrl,
    );

    return _navigator.showReviewSend(
      sendingAsset,
      _fee!,
      note,
    );
  }
}
