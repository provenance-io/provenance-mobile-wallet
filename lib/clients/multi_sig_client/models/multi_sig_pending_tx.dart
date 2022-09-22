import 'package:provenance_dart/proto.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_status.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signature.dart';

class MultiSigPendingTx {
  MultiSigPendingTx({
    required this.multiSigAddress,
    required this.signerAddress,
    required this.txUuid,
    required this.txBody,
    required this.fee,
    required this.status,
    this.signatures,
  });

  final String multiSigAddress;
  final String signerAddress;
  final String txUuid;
  final TxBody txBody;
  final Fee fee;
  final MultiSigStatus status;
  final List<MultiSigSignature>? signatures;
}
