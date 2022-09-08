import 'dart:async';
import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:fixnum/fixnum.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/proto_gov.dart' as gov;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/classes/transaction_bloc.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/denom_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class DepositConfirmBloc extends TransactionBloc {
  final Proposal _proposal;
  final BehaviorSubject<DepositDetails?> _depositDetails =
      BehaviorSubject.seeded(null);
  final _isLoading = BehaviorSubject.seeded(false);

  DepositConfirmBloc(
    TransactableAccount account,
    this._proposal,
  ) : super(account);

  ValueStream<DepositDetails?> get depositDetails => _depositDetails;

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading.tryAdd(true);
    }

    try {
      final asset =
          (await get<AssetService>().getAssets(account.coin, account.address))
              .firstWhere((element) => element.denom == 'nhash');

      _depositDetails.tryAdd(
        DepositDetails(
            hashAmount: nHashToHash(BigInt.parse(asset.amount)).toDouble(),
            proposal: _proposal),
      );
    } finally {
      if (showLoading) {
        _isLoading.tryAdd(false);
      }
    }
  }

  @override
  gov.MsgDeposit getMessage() {
    final _deposit = _depositDetails.value!;
    final scaledValue =
        hashToNHash(Decimal.parse(_deposit.amount.toInt().toString()))
            .toString();
    return gov.MsgDeposit(
      amount: [
        proto.Coin(
          amount: scaledValue,
          denom: nHashDenom,
        ),
      ],
      depositor: account.address,
      proposalId: Int64(_proposal.proposalId),
    );
  }

  double get depositAmount {
    return _depositDetails.value!.amount.toDouble();
  }

  set depositAmount(double newValue) {
    final oldDetails = _depositDetails.value!;
    _depositDetails.tryAdd(
      DepositDetails(
        amount: newValue,
        hashAmount: oldDetails.hashAmount,
        proposal: oldDetails.proposal,
      ),
    );
  }

  @override
  FutureOr onDispose() {
    _depositDetails.close();
  }

  Uri getProvUrl() {
    switch (account.coin) {
      case Coin.testNet:
        return Uri.https(
            'explorer.test.provenance.io', '/proposal/${_proposal.proposalId}');
      case Coin.mainNet:
        return Uri.https(
            'explorer.provenance.io', '/proposal/${_proposal.proposalId}');
    }
  }
}

class DepositDetails {
  DepositDetails({
    this.amount = 0,
    this.hashAmount = 0,
    this.proposal,
  });

  final double amount;
  final double hashAmount;
  final Proposal? proposal;

  double get currentDepositHash {
    return nHashToHash(BigInt.parse(proposal?.currentDeposit ?? "0"))
        .toDouble();
  }

  double get sliderMax {
    return min(
        nHashToHash(BigInt.parse(proposal?.neededDeposit ?? "0")).toDouble(),
        hashAmount);
  }

  double get neededDepositHash {
    return nHashToHash(BigInt.parse(proposal?.neededDeposit ?? "0")).toDouble();
  }
}
