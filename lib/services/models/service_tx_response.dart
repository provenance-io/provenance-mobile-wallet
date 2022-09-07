import 'package:provenance_dart/proto.dart' as proto;

class ServiceTxResponse {
  ServiceTxResponse({
    required this.code,
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

  final String? message;
  final int? gasWanted;
  final int? gasUsed;
  final int? height;
  final String? txHash;
  final List<proto.Coin>? fees;
  final proto.Tx? tx;
  final String? codespace;
}
