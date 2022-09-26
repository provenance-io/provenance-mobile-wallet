import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_wallet/services/tx_queue_client/models/sembast_gas_estimate.dart';
import 'package:provenance_wallet/services/tx_queue_client/models/sembast_tx_signer.dart';

class SembastScheduledTx {
  SembastScheduledTx({
    required this.accountId,
    required this.txBody,
    this.gasEstimate,
    this.remoteId,
    this.signers,
  });

  final String accountId;
  final proto.TxBody txBody;
  final SembastGasEstimate? gasEstimate;
  final String? remoteId;
  final List<SembastTxSigner>? signers;

  SembastScheduledTx copyWith({List<SembastTxSigner>? signers}) =>
      SembastScheduledTx(
        accountId: accountId,
        txBody: txBody,
        gasEstimate: gasEstimate,
        remoteId: remoteId,
        signers: signers ?? this.signers,
      );

  Map<String, Object?> toRecord() => {
        'accountId': accountId,
        'txBody': txBody.writeToJson(),
        if (gasEstimate != null) 'gasEstimate': gasEstimate?.toRecord(),
        'remoteId': remoteId,
        if (signers != null)
          'signers': signers?.map((e) => e.toRecord()).toList(),
      };

  factory SembastScheduledTx.fromRecord(Map<String, Object?> rec) =>
      SembastScheduledTx(
        accountId: rec['accountId'] as String,
        txBody: proto.TxBody.fromJson(rec['txBody'] as String),
        gasEstimate: rec.containsKey('gasEstimate')
            ? SembastGasEstimate.fromRecord(
                rec['gasEstimate'] as Map<String, Object?>)
            : null,
        remoteId: rec['remoteId'] as String?,
        signers: rec.containsKey('signers')
            ? (rec['signers'] as List<Map<String, Object?>>)
                .map((e) => SembastTxSigner.fromRecord(e))
                .toList()
            : null,
      );
}
