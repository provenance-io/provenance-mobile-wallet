import 'package:provenance_dart/proto.dart';

class MultiSigPendingTx {
  MultiSigPendingTx({
    required this.accountAddress,
    required this.txUuid,
    required this.txBody,
  });

  final String accountAddress;
  final String txUuid;
  final TxBody txBody;
}
