import 'package:provenance_dart/proto.dart' as proto;

class MultiSigTxBodyBytesDto {
  MultiSigTxBodyBytesDto({
    required this.txBody,
    required this.fee,
  });

  final proto.TxBody txBody;
  final proto.Fee fee;

  factory MultiSigTxBodyBytesDto.fromJson(Map<String, dynamic> json) {
    final txBody = json['txBody'];
    final fee = json['fee'];

    return MultiSigTxBodyBytesDto(
      txBody: proto.TxBody.fromJson(txBody),
      fee: proto.Fee.fromJson(fee),
    );
  }

  Map<String, dynamic> toJson() => {
        'txBody': txBody.writeToJson(),
        'fee': fee.writeToJson(),
      };
}
