import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart' as wallet;
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/models/account.dart';

abstract class TxQueueService {
  Stream<TxResult> get response;

  Future<AccountGasEstimate> estimateGas({
    required proto.TxBody txBody,
    required TransactableAccount account,
  });

  Future<ScheduledTx> scheduleTx({
    required proto.TxBody txBody,
    required TransactableAccount account,
    required AccountGasEstimate gasEstimate,
  });

  Future<void> completeTx({
    required String txId,
  });

  Future<bool> signTx({
    required String txId,
    required String signerAddress,
    required String multiSigAddress,
    required proto.TxBody txBody,
    required proto.Fee fee,
  });

  Future<bool> declineTx({
    required String signerAddress,
    required String txId,
    required wallet.Coin coin,
  });
}

class ScheduledTx {
  ScheduledTx({
    this.txId,
    this.result,
  });

  final String? txId;
  final TxResult? result;
}

class TxResult {
  TxResult({
    required this.body,
    required this.response,
    required this.fee,
    this.txId,
  });

  final proto.TxBody body;
  final proto.RawTxResponsePair response;
  final proto.Fee fee;
  final String? txId;
}

class AccountTransactionResponse {
  AccountTransactionResponse({
    required this.txBody,
    required this.status,
    this.txResponse,
    this.txId,
    this.gasEstimate,
  });

  final proto.TxBody txBody;
  final AccountTransactionStatus status;
  final proto.TxResponse? txResponse;
  final String? txId;
  final AccountGasEstimate? gasEstimate;
}

enum AccountTransactionStatus {
  fail,
  pending,
  complete,
}
