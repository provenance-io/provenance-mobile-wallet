import 'package:provenance_blockchain_wallet/services/wallet_service/model/wallet_gas_estimate.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet.dart';

abstract class TransactionHandler {
  Stream<TransactionResponse> get transaction;

  Future<WalletGasEstimate> estimateGas(TxBody txBody, PublicKey publicKey);

  Future<RawTxResponsePair> executeTransaction(
    TxBody txBody,
    PrivateKey privateKey, [
    WalletGasEstimate? gasEstimate,
  ]);
}

class TransactionResponse {
  TransactionResponse({
    required this.txBody,
    required this.txResponse,
    this.gasEstimate,
  });

  final TxBody txBody;
  final TxResponse txResponse;
  final WalletGasEstimate? gasEstimate;
}
