import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart' as wallet;
import 'package:provenance_wallet/gas_fee_estimate.dart';
import 'package:provenance_wallet/services/models/account.dart';

abstract class TxQueueService {
  Stream<TxResult> get response;

  Future<GasFeeEstimate> estimateGas({
    required proto.TxBody txBody,
    required TransactableAccount account,
    double? gasAdjustment,
  });

  Future<QueuedTx> scheduleTx({
    required proto.TxBody txBody,
    required TransactableAccount account,
    required GasFeeEstimate gasEstimate,
    int? walletConnectRequestId,
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

class ExecutedTx implements QueuedTx {
  ExecutedTx({
    required this.result,
  });

  @override
  final kind = QueuedTxKind.executed;

  final TxResult result;
}

class ScheduledTx implements QueuedTx {
  ScheduledTx({
    required this.txId,
  });

  @override
  final kind = QueuedTxKind.scheduled;

  final String txId;
}

abstract class QueuedTx {
  QueuedTxKind get kind;
}

enum QueuedTxKind {
  executed,
  scheduled;
}

class TxResult {
  TxResult({
    required this.body,
    required this.response,
    required this.fee,
    this.txId,
    this.walletConnectRequestId,
  });

  final proto.TxBody body;
  final proto.RawTxResponsePair response;
  final proto.Fee fee;
  final String? txId;
  final int? walletConnectRequestId;
}
