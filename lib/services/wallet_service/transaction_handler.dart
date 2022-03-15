import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/wallet_service/model/wallet_gas_estimate.dart';

abstract class TransactionHandler {
  Future<WalletGasEstimate> estimateGas(TxBody txBody, PublicKey publicKey);

  Future<RawTxResponsePair> executeTransaction(
    TxBody txBody,
    PrivateKey privateKey, [
    WalletGasEstimate? gasEstimate,
  ]);
}
