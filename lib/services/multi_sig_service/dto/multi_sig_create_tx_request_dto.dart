import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_create_tx_request_dto.g.dart';

@JsonSerializable()
class MultiSigCreateTxRequestDto {
  MultiSigCreateTxRequestDto({
    required this.multiSigAddress,
    required this.signerAddress,
    required this.txBodyBytes,
  });

  @JsonKey(name: 'walletAddress')
  final String multiSigAddress;

  @JsonKey(name: 'accountAddress')
  final String signerAddress;

  final String txBodyBytes;

  // ignore: member-ordering
  factory MultiSigCreateTxRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigCreateTxRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigCreateTxRequestDtoToJson(this);
}
