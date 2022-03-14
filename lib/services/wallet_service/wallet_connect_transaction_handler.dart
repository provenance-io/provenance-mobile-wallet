import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/extension/coin_helper.dart';
import 'package:provenance_wallet/services/gas_fee_service/gas_fee_service.dart';
import 'package:provenance_wallet/services/wallet_service/transaction_handler.dart';
import 'package:provenance_wallet/util/get.dart';

class WalletConnectTransactionHandler implements TransactionHandler {
  @override
  Future<proto.GasEstimate> estimateGas(
    proto.TxBody txBody,
    PublicKey publicKey,
  ) async {
    final coin = publicKey.coin;
    final pbClient = proto.PbClient(Uri.parse(coin.address), coin.chainId);

    final account = await pbClient.getBaseAccount(publicKey.address);
    final signer = _EstimateSigner(account.address, publicKey);
    final baseReqSigner = proto.BaseReqSigner(signer, account);

    final baseReq = proto.BaseReq(
      txBody,
      [baseReqSigner],
      coin.chainId,
    );

    final gasService = get<GasFeeService>();

    final estimate = await pbClient.estimateTx(baseReq);
    final customFee = await gasService.getGasFee();

    if (customFee != null) {
      final calculatedAmount = customFee.amount * estimate.estimate;
      final calculatedCoin = proto.Coin(
        denom: customFee.denom,
        amount: calculatedAmount.toString(),
      );

      final index = estimate.feeCalculated!
          .indexWhere((coin) => coin.denom == customFee.denom);

      if (index >= 0) {
        if (calculatedAmount >
            int.parse(estimate.feeCalculated![index].amount)) {
          estimate.feeCalculated![index] = calculatedCoin;
        }
      } else {
        estimate.feeCalculated!.add(calculatedCoin);
      }
    }

    return estimate;
  }

  @override
  Future<proto.RawTxResponsePair> executeTransaction(
    proto.TxBody txBody,
    PrivateKey privateKey, [
    proto.GasEstimate? gasEstimate,
  ]) async {
    final publicKey = privateKey.defaultKey().publicKey;
    final coin = publicKey.coin;

    final pbClient = proto.PbClient(Uri.parse(coin.address), coin.chainId);
    final account = await pbClient.getBaseAccount(publicKey.address);
    final signer = _SignerImp(privateKey);

    final baseReqSigner = proto.BaseReqSigner(signer, account);

    gasEstimate ??= await estimateGas(txBody, publicKey);

    final baseReq = proto.BaseReq(
      txBody,
      [baseReqSigner],
      coin.chainId,
    );

    return pbClient
        .broadcastTx(
      baseReq,
      gasEstimate,
      proto.BroadcastMode.BROADCAST_MODE_BLOCK,
    )
        .then((response) {
      if (response.txResponse.code != 0 ||
          (response.txResponse.code == 0 && response.txResponse.height == 0)) {
        throw Exception(response.txResponse.rawLog);
      }

      return response;
    });
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
