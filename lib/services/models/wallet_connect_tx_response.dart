import 'package:provenance_dart/proto.dart' as proto;

class WalletConnectTxResponse {
  WalletConnectTxResponse({
    required this.code,
    required this.requestId,
    this.message,
    this.gasWanted,
    this.gasUsed,
    this.height,
    this.txHash,
    this.fees,
    this.tx,
    this.codespace,
  });

  final int code;
  final String requestId;
  final String? message;
  final int? gasWanted;
  final int? gasUsed;
  final int? height;
  final String? txHash;
  final List<proto.Coin>? fees;
  final proto.Tx? tx;
  final String? codespace;
}
