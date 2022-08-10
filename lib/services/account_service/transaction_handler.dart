import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';

abstract class TransactionHandler {
  Stream<TransactionResponse> get transaction;

  Future<AccountGasEstimate> estimateGas(
    proto.TxBody txBody,
    String signerAddress,
  );

  Future<proto.RawTxResponsePair> executeTransaction(
    proto.TxBody txBody,
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

  final proto.TxBody txBody;
  final proto.TxResponse txResponse;
  final AccountGasEstimate? gasEstimate;
}
