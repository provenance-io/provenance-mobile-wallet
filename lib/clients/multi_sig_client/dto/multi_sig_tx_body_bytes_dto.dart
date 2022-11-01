import 'package:provenance_dart/proto.dart' as proto;

class MultiSigTxBodyBytesDto {
  MultiSigTxBodyBytesDto({
    required this.txBody,
    required this.fee,
    this.walletConnectRequestId,
  });

  final proto.TxBody txBody;
  final proto.Fee fee;
  final int? walletConnectRequestId;

  factory MultiSigTxBodyBytesDto.fromJson(Map<String, dynamic> json) {
    final txBody = json['txBody'];
    final fee = json['fee'];
    final walletConnectRequestId = json['walletConnectRequestId'] as int?;

    return MultiSigTxBodyBytesDto(
      txBody: proto.TxBody.fromJson(txBody),
      fee: proto.Fee.fromJson(fee),
      walletConnectRequestId: walletConnectRequestId,
    );
  }

  Map<String, dynamic> toJson() => {
        'txBody': txBody.writeToJson(),
        'fee': fee.writeToJson(),
        if (walletConnectRequestId != null)
          'walletConnectRequestId': walletConnectRequestId,
      };
}
