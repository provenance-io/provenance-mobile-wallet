import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_sign_tx_request_dto.g.dart';

@JsonSerializable()
class MultiSigSignTxRequest {
  MultiSigSignTxRequest({
    required this.address,
    required this.txUuid,
    this.signatureBytes,
    this.declineTx,
  });

  final String address;
  final String txUuid;
  final String? signatureBytes;
  final bool? declineTx;

  factory MultiSigSignTxRequest.fromJson(Map<String, dynamic> json) =>
      _$MultiSigSignTxRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigSignTxRequestToJson(this);
}
