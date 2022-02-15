import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/transaction_handler.dart';
import 'package:provenance_wallet/extension/coin_helper.dart';

class WalletConnectTransactionHandler implements TransactionHandler {
  @override
  Future<GasEstimate> estimateGas(
    TxBody txBody,
    PrivateKey privateKey,
  ) async {
    final publicKey = privateKey.defaultKey().publicKey;
    final coin = publicKey.coin;
    final pbClient = PbClient(Uri.parse(coin.address), coin.chainId);

    final account = await pbClient.getBaseAccount(publicKey.address);
    final signer = _SignerImp(privateKey);
    final baseReqSigner = BaseReqSigner(signer, account);

    final baseReq = BaseReq(
      txBody,
      [baseReqSigner],
      coin.chainId,
    );

    return pbClient.estimateTx(baseReq);
  }

  @override
  Future<RawTxResponsePair> executeTransaction(
    TxBody txBody,
    PrivateKey privateKey,
  ) async {
    final publicKey = privateKey.defaultKey().publicKey;
    final coin = publicKey.coin;

    final pbClient = PbClient(Uri.parse(coin.address), coin.chainId);
    final account = await pbClient.getBaseAccount(publicKey.address);
    final signer = _SignerImp(privateKey);

    final baseReqSigner = BaseReqSigner(signer, account);

    return pbClient.estimateAndBroadcastTx(txBody, [baseReqSigner]);
  }
}

class _SignerImp implements Signer {
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
