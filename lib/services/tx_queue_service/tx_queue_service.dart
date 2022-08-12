import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/models/account.dart';

abstract class TxQueueService {
  Future<AccountGasEstimate> estimateGas({
    required proto.TxBody txBody,
    required TransactableAccount account,
  });

  Future<ScheduleTxResponse> scheduleTx({
    required proto.TxBody txBody,
    required TransactableAccount account,
    AccountGasEstimate? gasEstimate,
  });

  Future<void> completeTx({
    required String remoteTxId,
    required List<TxSigner> signers,
  });
}

class ScheduleTxResponse {
  ScheduleTxResponse({
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
  final proto.TxResponse response;
}

class TxSigner {
  TxSigner({
    required this.publicKey,
    required this.signature,
    required this.signerOrder,
  });

  final String publicKey;
  final String signature;
  final int signerOrder;
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
