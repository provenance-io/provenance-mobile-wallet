import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_tx_signature_dto.g.dart';

@JsonSerializable()
class MultiSigTxSignatureDto {
  MultiSigTxSignatureDto({
    required this.signerAddress,
    required this.signatureDecline,
    this.signatureHex,
  });

  final String signerAddress;
  final bool signatureDecline;

  @JsonKey(name: 'signatureBytes')
  final String? signatureHex;

  factory MultiSigTxSignatureDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigTxSignatureDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigTxSignatureDtoToJson(this);
}
