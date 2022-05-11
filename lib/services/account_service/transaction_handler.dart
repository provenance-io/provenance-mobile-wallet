import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';

abstract class TransactionHandler {
  Stream<TransactionResponse> get transaction;

  Future<AccountGasEstimate> estimateGas(TxBody txBody, PublicKey publicKey);

  Future<RawTxResponsePair> executeTransaction(
    TxBody txBody,
    PrivateKey privateKey, [
    AccountGasEstimate? gasEstimate,
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
  final AccountGasEstimate? gasEstimate;
}
