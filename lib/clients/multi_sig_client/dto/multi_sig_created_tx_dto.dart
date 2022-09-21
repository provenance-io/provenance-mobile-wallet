import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_status.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_tx_signature_dto.dart';

part 'multi_sig_created_tx_dto.g.dart';

@JsonSerializable()
class MultiSigCreatedTxDto {
  MultiSigCreatedTxDto({
    required this.multiSigAddress,
    required this.signerAddress,
    required this.txUuid,
    required this.txBodyBytes,
    required this.status,
    this.signatures,
  });

  final String multiSigAddress;
  final String signerAddress;
  final String txUuid;
  final String txBodyBytes;
  final MultiSigStatus status;
  final List<MultiSigTxSignatureDto>? signatures;

  factory MultiSigCreatedTxDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigCreatedTxDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigCreatedTxDtoToJson(this);
}
