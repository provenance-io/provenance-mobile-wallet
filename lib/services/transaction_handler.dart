import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet.dart';

abstract class TransactionHandler {
  Future<GasEstimate> estimateGas(TxBody txBody, PrivateKey privateKey);

  Future<RawTxResponsePair> executeTransaction(
    TxBody txBody,
    PrivateKey privateKey,
  );
}
