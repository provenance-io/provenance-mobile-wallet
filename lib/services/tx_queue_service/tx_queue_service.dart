import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/models/account.dart';

import 'models/service_tx_response.dart';

abstract class TxQueueService {
  Stream<ServiceTxResponse> get response;

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
    required String txUuid,
  });

  Future<bool> signTx({
    required String txId,
    required String signerAddress,
    required String multiSigAddress,
    required proto.TxBody txBody,
    required proto.Fee fee,
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
  });

  final proto.TxBody body;
  final proto.RawTxResponsePair response;
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
