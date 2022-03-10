import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet.dart';

abstract class TransactionHandler {
  Future<GasEstimate> estimateGas(TxBody txBody, PublicKey publicKey);

  Future<RawTxResponsePair> executeTransaction(
    TxBody txBody,
    PrivateKey privateKey, [
    GasEstimate? gasEstimate,
  ]);
}
