import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/gas_fee_estimate.dart';

abstract class TransactionHandler {
  Stream<TransactionResponse> get transaction;

  Future<GasFeeEstimate> estimateGas(
    proto.TxBody txBody,
    List<IPubKey> signers,
    Coin coin, {
    double? gasAdjustment,
  });

  Future<proto.RawTxResponsePair> executeTransaction(
    proto.TxBody txBody,
    IPrivKey privateKey,
    Coin coin, [
    GasFeeEstimate? gasEstimate,
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
  final GasFeeEstimate? gasEstimate;
}
