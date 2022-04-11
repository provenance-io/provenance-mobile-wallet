import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/gas_fee_service/gas_fee_service.dart';
import 'package:provenance_wallet/services/wallet_service/model/wallet_gas_estimate.dart';
import 'package:provenance_wallet/services/wallet_service/transaction_handler.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/subjects.dart';

typedef ProtobuffClientInjector = proto.PbClient Function(Coin coin);

class WalletConnectTransactionHandler
    implements TransactionHandler, Disposable {
  final _transaction = PublishSubject<TransactionResponse>();

  @override
  Stream<TransactionResponse> get transaction => _transaction;

  @override
  FutureOr onDispose() {
    _transaction.close();
  }

  @override
  Future<WalletGasEstimate> estimateGas(
    proto.TxBody txBody,
    PublicKey publicKey,
  ) async {
    final coin = publicKey.coin;

    final protoBuffInjector = get<ProtobuffClientInjector>();
    final pbClient = protoBuffInjector(coin);

    final account = await pbClient.getBaseAccount(publicKey.address);
    final signer = _EstimateSigner(account.address, publicKey);
    final baseReqSigner = proto.BaseReqSigner(signer, account);

    final baseReq = proto.BaseReq(
      txBody,
      [baseReqSigner],
      pbClient.chainId,
    );

    final gasService = get<GasFeeService>();

    final estimate = await pbClient.estimateTx(baseReq);
    final customFee = await gasService.getGasFee(coin);

    return WalletGasEstimate(
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
    WalletGasEstimate? gasEstimate,
  ]) async {
    final publicKey = privateKey.defaultKey().publicKey;
    final coin = publicKey.coin;
    final protoBuffInjector = get<ProtobuffClientInjector>();

    final pbClient = protoBuffInjector(coin);

    final account = await pbClient.getBaseAccount(publicKey.address);
    final signer = _SignerImp(privateKey);

    final baseReqSigner = proto.BaseReqSigner(signer, account);

    gasEstimate ??= await estimateGas(txBody, publicKey);

    final baseReq = proto.BaseReq(
      txBody,
      [baseReqSigner],
      pbClient.chainId,
    );

    final responsePair = await pbClient.broadcastTx(
      baseReq,
      gasEstimate,
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

class _SignerImp implements proto.Signer {
  _SignerImp(this._privateKey);

  final PrivateKey _privateKey;

  @override
  String get address => pubKey.address;

  @override
  PublicKey get pubKey => _privateKey.defaultKey().publicKey;

  @override
  List<int> sign(List<int> data) {
    return _privateKey.defaultKey().signData(Hash.sha256(data))..removeLast();
  }
}

class _EstimateSigner extends proto.Signer {
  _EstimateSigner(this._address, this._publicKey);

  final String _address;
  final PublicKey _publicKey;

  @override
  String get address => _address;

  @override
  PublicKey get pubKey => _publicKey;
  @override
  List<int> sign(List<int> data) {
    return <int>[];
  }
}
