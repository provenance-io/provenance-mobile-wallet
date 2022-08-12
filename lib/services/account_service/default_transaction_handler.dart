import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/gas_fee_service/gas_fee_service.dart';
import 'package:provenance_wallet/util/address_util.dart';
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
  Future<AccountGasEstimate> estimateGas(
    proto.TxBody txBody,
    List<IPubKey> signers,
  ) async {
    final protoBuffInjector = get<ProtobuffClientInjector>();
    final coin = getCoinFromAddress(signers[0].address);
    final pbClient = await protoBuffInjector(coin);

    final gasService = get<GasFeeService>();

    final estimate = await pbClient.estimateTransactionFees(
      txBody,
      signers,
    );
    final customFee = await gasService.getGasFee(coin);

    return AccountGasEstimate(
      estimate.estimate,
      customFee?.amount,
      estimate.feeAdjustment,
      estimate.feeCalculated,
    );
  }

  @override
  Future<proto.RawTxResponsePair> executeTransaction(
    proto.TxBody txBody,
    PrivateKey privateKey, [
    AccountGasEstimate? gasEstimate,
  ]) async {
    final protoBuffInjector = get<ProtobuffClientInjector>();

    final publicKey = privateKey.defaultKey().publicKey;
    final coin = getCoinFromAddress(publicKey.address);
    final pbClient = await protoBuffInjector(coin);

    gasEstimate ??= await estimateGas(txBody, [publicKey]);

    final fee = proto.Fee(
      amount: gasEstimate.totalFees,
      gasLimit: proto.Int64(gasEstimate.estimatedGas),
    );

    final responsePair = await pbClient.broadcastTransaction(
      txBody,
      [
        privateKey.defaultKey(),
      ],
      fee,
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
