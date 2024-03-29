import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/gas_fee_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/gas_fee/gas_fee_client.dart';
import 'package:provenance_wallet/services/models/gas_price.dart';
import 'package:provenance_wallet/util/constants.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/subjects.dart';

typedef ProtobuffClientInjector = Future<proto.PbClient> Function(Coin coin);

class DefaultTransactionHandler implements TransactionHandler, Disposable {
  final _transaction = PublishSubject<TransactionResponse>();

  @override
  Stream<TransactionResponse> get transaction => _transaction;

  @override
  FutureOr onDispose() {
    _transaction.close();
  }

  @override
  Future<GasFeeEstimate> estimateGas(
    proto.TxBody txBody,
    List<IPubKey> signers,
    Coin coin, {
    double? gasAdjustment,
  }) async {
    final protoBuffInjector = get<ProtobuffClientInjector>();
    final pbClient = await protoBuffInjector(coin);

    final gasService = get<GasFeeClient>();

    final estimate = await pbClient.estimateTransactionFees(
      txBody,
      signers,
      gasAdjustment: gasAdjustment ?? defaultGasAdjustment,
    );

    // make sure that we are using the largest gas fee
    final gasPrice = await gasService.getPrice(coin);

    final priceLookup = <String, double>{};
    if (gasPrice != null) {
      priceLookup[gasPrice.denom] = gasPrice.amountPerUnit.toDouble();
    }

    for (proto.Coin fee in estimate.feeCalculated ?? <proto.Coin>[]) {
      final value = (int.parse(fee.amount) / estimate.estimate);
      final previousValue = priceLookup[fee.denom] ?? 0;
      if (value > previousValue) {
        priceLookup[fee.denom] = value;
      }
    }

    final fees = priceLookup.entries
        .map((entry) => GasPrice(denom: entry.key, amountPerUnit: entry.value))
        .toList();

    return GasFeeEstimate(
      estimate.estimate,
      fees,
    );
  }

  @override
  Future<proto.RawTxResponsePair> executeTransaction(
    proto.TxBody txBody,
    IPrivKey privateKey,
    Coin coin, [
    GasFeeEstimate? gasEstimate,
  ]) async {
    final protoBuffInjector = get<ProtobuffClientInjector>();

    final publicKey = privateKey.publicKey;
    final pbClient = await protoBuffInjector(coin);

    gasEstimate ??= await estimateGas(txBody, [publicKey], coin);

    final responsePair = await pbClient.broadcastTransaction(
      txBody,
      [
        privateKey,
      ],
      gasEstimate.toProtoFee(),
      proto.BroadcastMode.BROADCAST_MODE_BLOCK,
    );

    _transaction.add(
      TransactionResponse(
        txBody: txBody,
        txResponse: responsePair.txResponse,
        gasEstimate: gasEstimate,
      ),
    );

    return responsePair;
  }
}
