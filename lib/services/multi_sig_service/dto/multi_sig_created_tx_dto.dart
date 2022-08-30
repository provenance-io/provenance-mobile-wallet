import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_tx_signature_dto.dart';

part 'multi_sig_created_tx_dto.g.dart';

@JsonSerializable()
class MultiSigCreatedTxDto {
  MultiSigCreatedTxDto({
    required this.multiSigAddress,
    required this.txUuid,
    required this.txBodyBytes,
    required this.status,
    this.signatures,
  });

  final String multiSigAddress;
  final String txUuid;
  final String txBodyBytes;
  final String status;
  final List<MultiSigTxSignatureDto>? signatures;

  factory MultiSigCreatedTxDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigCreatedTxDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigCreatedTxDtoToJson(this);
}
