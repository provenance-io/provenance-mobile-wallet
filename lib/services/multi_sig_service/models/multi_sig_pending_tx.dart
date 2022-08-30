import 'package:provenance_dart/proto.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_signature.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_status.dart';

class MultiSigPendingTx {
  MultiSigPendingTx({
    required this.multiSigAddress,
    required this.txUuid,
    required this.txBody,
    required this.fee,
    required this.status,
    this.signatures,
  });

  final String multiSigAddress;
  final String txUuid;
  final TxBody txBody;
  final Fee fee;
  final MultiSigStatus status;
  final List<MultiSigSignature>? signatures;
}
